import config from "config"; // Airdrop config
import { eth } from "state/eth"; // ETH state provider
import { ethers } from "ethers"; // Ethers
import keccak256 from "keccak256"; // Keccak256 hashing
import MerkleTree from "merkletreejs"; // MerkleTree.js
import { useEffect, useState } from "react"; // React
import { createContainer } from "unstated-next"; // State management
import { signERC2612Permit, signDaiPermit } from "eth-permit";


function generateLeaf(address: string, value: string): Buffer {
  return Buffer.from(
    ethers.utils
      .solidityKeccak256(["address", "uint256"], [address, value])
      .slice(2),
    "hex"
  );
}

const merkleTree = new MerkleTree(
  Object.entries(config.airdrop).map(([address, tokens]) =>
    generateLeaf(
      ethers.utils.getAddress(address),
      ethers.utils.parseUnits(tokens.toString(), config.decimals).toString()
    )
  ),
  keccak256,
  { sortPairs: true }
);

function useToken() {
  const {
    address,
    provider,
  }: {
    address: string | null;
    provider: ethers.providers.Web3Provider | null;
  } = eth.useContainer();

  const [dataLoading, setDataLoading] = useState<boolean>(true); // Data retrieval status
  const [numTokens, setNumTokens] = useState<number>(0); // Number of claimable tokens
  const [alreadyClaimed, setAlreadyClaimed] = useState<boolean>(false); // Claim status
  const [claimedAmount, setClaimedAmount] = useState<number>(0); // Claim status

  const getContract = (address: string, abi: string[]): ethers.Contract => {
    return new ethers.Contract(
      address,
      abi,
      provider?.getSigner()
    );
  };

  /**
   * Collects number of tokens claimable by a user from Merkle tree
   * @param {string} address to check
   * @returns {number} of tokens claimable
   */
  const getAirdropAmount = (address: string): number => {
    const test = ethers.utils.getAddress(address)
    if (config.airdrop[test]) {
      return config.airdrop[test];
    }
    return 0;
  };

  const claimAirdrop = async (value: number, ticker: string): Promise<void> => {
    if (!address) {
      throw new Error("Not Authenticated");
    }
    const parsedValue = ethers.utils.parseUnits(value.toString(), config.decimals).toString();
    // Amount sender is purchasing derived from argument passed from state
    const amountPurchased = parsedValue;
    // Cleaning address 
    const formattedAddress: string = ethers.utils.getAddress(address);
    // Max tokens that can be purchased by current whitelisted address
    const indexOfTokens = config.airdrop[formattedAddress];
    // Generating a leaf based on user address and tokens
    const leaf = generateLeaf(
      ethers.utils.getAddress(address),
      ethers.utils.parseUnits(indexOfTokens.toString(), config.decimals).toString()
    )

    // MERKLE ROOT CREATION/DATA
    const merkleRoot: string = merkleTree.getHexRoot();
    const proof: string[] = merkleTree.getHexProof(leaf);
    console.log(`Proof: ${proof}`);
    console.log(`Merkle Root: ${merkleRoot}`);

    try {
      // Switch for production
      const spender: string = 'ptoken contract';
      if (ticker === 'DAI') {
        const token: ethers.Contract = getContract("Address", [ticker]);
        const result = await signDaiPermit(provider, ticker, formattedAddress, spender);
        await token.methods.permit(formattedAddress, spender, result.nonce, result.expiry, true, result.v, result.r, result.s).send({
          from: formattedAddress,
        });
        const tx = await token.claim(formattedAddress, indexOfTokens, proof);
        await tx.wait(1);
        await syncStatus();
      } else {
        const token: ethers.Contract = getContract("Address", [ticker]);
        const result = await signERC2612Permit(provider, ticker, formattedAddress, spender, amountPurchased);
        await token.methods.permit(formattedAddress, spender, amountPurchased, result.deadline, result.v, result.r, result.s).send({
          from: formattedAddress,
        });
        // add arguments for the claim function!
        const tx = await token.claim(formattedAddress, indexOfTokens, proof);
        await tx.wait(1);
        await syncStatus();
      }
    } catch (e) {
      console.error(`Error when claiming tokens: ${e}`);
    }
  };

  const syncStatus = async (): Promise<void> => {
    setDataLoading(true);
    if (address) {
      // const pCNV: ethers.Contract = getContract("0xf8e81D47203A594245E36C48e151709F0C19fBe8", [abi]);
      // const merkle: ethers.Contract = getContract("0xf8e81D47203A594245E36C48e151709F0C19fBe8", [abi]);
      // const pCNVbalanceOfAddress = pCNV.balanceOf(address);
      // const claimedAmount = merkle.claimed(address);
      // Set amount still eligible to claim
      const maxAmountForAddress = getAirdropAmount(address);
      // setNumTokens(claimable); (change line 104 to this)
      setNumTokens(maxAmountForAddress);
      // If current user
      // if (pCNVBalanceOfAddress < maxAmountForAddress) {
      //   setAlreadyClaimed(false);
      //   setClaimedAmount(claimedAmount)
      // }
    }
    setDataLoading(false);
  };

  // On load:
  useEffect(() => {
    syncStatus();
  }, [address]);

  return {
    dataLoading,
    numTokens,
    alreadyClaimed,
    claimAirdrop,
    address,
    claimedAmount
  };
}

export const token = createContainer(useToken);


// Merkel data if needed
// const leafData = config.airdrop[formattedAddress];
// const indexOfLeaf = merkleTree.getLeafIndex(leaf);
// const getHexLeaf: Buffer = merkleTree.getHexLeaves();
// const indexedHexLeaf: Buffer = getHexLeaf[indexOfLeaf];
