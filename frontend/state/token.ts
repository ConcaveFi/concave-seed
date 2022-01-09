import config from "config"; // Airdrop config
import { eth } from "state/eth"; // ETH state provider
import { ethers } from "ethers"; // Ethers
import keccak256 from "keccak256"; // Keccak256 hashing
import MerkleTree from "merkletreejs"; // MerkleTree.js
import { useEffect, useState } from "react"; // React
import { createContainer } from "unstated-next"; // State management

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

  /**
   * Get contract
   * @returns {ethers.Contract} signer-initialized contract
   */
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

  const claimAirdrop = async (): Promise<void> => {

    if (!address) {
      throw new Error("Not Authenticated");
    }

    const formattedAddress: string = ethers.utils.getAddress(address);
    const indexOfTokens = config.airdrop[formattedAddress];
    const leafData = config.airdrop[formattedAddress];
    const leaf =  generateLeaf(
      ethers.utils.getAddress(address),
      ethers.utils.parseUnits(indexOfTokens.toString(), config.decimals).toString()
    )
    const indexOfLeaf = merkleTree.getLeafIndex(leaf);
    const merkleRoot: string = merkleTree.getHexRoot();
    const proof: string[] = merkleTree.getHexProof(leaf);
    const getHexLeaf: Buffer = merkleTree.getHexLeaves();
    const indexedHexLeaf: Buffer = getHexLeaf[indexOfLeaf];
    console.log(`Proof: ${proof}`)
    console.log(`Merkle Root: ${merkleRoot}`);

    try {
    const token: ethers.Contract = getContract("ABI", ["0xf8e81D47203A594245E36C48e151709F0C19fBe8"]);
    const tx = await token.claim(formattedAddress, indexOfTokens, proof);
      await tx.wait(1);
      await syncStatus();
    } catch (e) {
      console.error(`Error when claiming tokens: ${e}`);
    }
  };

  /**
   * After authentication, update number of tokens to claim + claim status
   */
  const syncStatus = async (): Promise<void> => {
    setDataLoading(true);
    if (address) {
      const maxAmtForAddress = getAirdropAmount(address);
      // SWITCH ADDRESS TO PRODUCTION FOR 135
      // const token: ethers.Contract = getContract( pCNVAbi,"0xf8e81D47203A594245E36C48e151709F0C19fBe8");
      // const pCNVbalance = token.balanceOf(address);
      //Set amount still eligible to claim = 
      // claimable = maxTokens - pCNVBalance
      // setNumTokens(claimable);
      setNumTokens(maxAmtForAddress);

      // if (pCNVBalance === maxTokens) {
      //   setAlreadyClaimed(true);
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
    address
  };
}

export const token = createContainer(useToken);
