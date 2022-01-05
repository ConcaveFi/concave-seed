import config from "config"; // Airdrop config
import { eth } from "state/eth"; // ETH state provider
import { ethers } from "ethers"; // Ethers
import keccak256 from "keccak256"; // Keccak256 hashing
import MerkleTree from "merkletreejs"; // MerkleTree.js
import { useEffect, useState } from "react"; // React
import { createContainer } from "unstated-next"; // State management

/**
 * Generate Merkle Tree leaf from address and value
 * @param {string} address of airdrop claimee
 * @param {string} value of airdrop tokens to claimee
 * @returns {Buffer} Merkle Tree node
 */
function generateLeaf(address: string, value: string): Buffer {

  return Buffer.from(
    // Hash in appropriate Merkle format
    ethers.utils
      .solidityKeccak256(["address", "uint256"], [address, value])
      .slice(2),
    "hex"
  );
}

// Setup merkle tree
const merkleTree = new MerkleTree(
  // Generate leafs
  Object.entries(config.airdrop).map(([address, tokens]) =>
    generateLeaf(
      ethers.utils.getAddress(address),
      ethers.utils.parseUnits(tokens.toString(), config.decimals).toString()
    )
  ),
  // Hashing function
  keccak256,
  { sortPairs: true }
);
const leaf : Buffer = generateLeaf(
  ethers.utils.getAddress("0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"),
  ethers.utils.parseUnits("1".toString(), 18).toString()
  )
console.log(leaf)
console.log(merkleTree.getProof);
const proof: string[] = merkleTree.getHexProof(leaf);
console.log(proof)
function useToken() {
  // Collect global ETH state
  const {
    address,
    provider,
  }: {
    address: string | null;
    provider: ethers.providers.Web3Provider | null;
  } = eth.useContainer();

  // Local state
  const [dataLoading, setDataLoading] = useState<boolean>(true); // Data retrieval status
  const [numTokens, setNumTokens] = useState<number>(0); // Number of claimable tokens
  const [alreadyClaimed, setAlreadyClaimed] = useState<boolean>(false); // Claim status

  /**
   * Get contract
   * @returns {ethers.Contract} signer-initialized contract
   */
  // const getContract = (): ethers.Contract => {
  //   return new ethers.Contract(
  //     // Contract address
  //     process.env.NEXT_PUBLIC_CONTRACT_ADDRESS ?? "",
  //     [
  //       // hasClaimed mapping
  //       "function hasClaimed(address) public view returns (bool)",
  //       // Claim function
  //       "function claim(address to, uint256 amount, bytes32[] calldata proof) external",
  //     ],
  //     // Get signer from authed provider
  //     provider?.getSigner()
  //   );
  // };

  /**
   * Collects number of tokens claimable by a user from Merkle tree
   * @param {string} address to check
   * @returns {number} of tokens claimable
   */
  const getAirdropAmount = (address: string): number => {
    // If address is in airdrop
    const test = ethers.utils.getAddress(address)

    console.log(test);
    
    if (config.airdrop[test]) {
      // Return number of tokens available
      return config.airdrop[test];
    }

    // Else, return 0 tokens
    return 0;
  };

  /**
   * Collects claim status for an address
   * @param {string} address to check
   * @returns {Promise<boolean>} true if already claimed, false if available
   */
  const getClaimedStatus = async (address: string): Promise<boolean> => {
    // // Collect token contract
    // const token: ethers.Contract = getContract();
    // // Return claimed status
    // return await token.hasClaimed(address);
  };

  const claimAirdrop = async (): Promise<void> => {
    // If not authenticated throw
    if (!address) {
      throw new Error("Not Authenticated");
    }

    // Collect token contract to gather user data
    // const token: ethers.Contract = getContract();
    // Get properly formatted address
    const formattedAddress: string = ethers.utils.getAddress(address);
    console.log('formatted address')
    console.log(typeof formattedAddress);
    // Get tokens for address
    
    const numTokens: string = ethers.utils.parseUnits("1".toString(), 18).toString()

    // Generate hashed leaf from address
    const leaf: Buffer = await generateLeaf(formattedAddress, numTokens);
    // Generate airdrop proof
    const proof: string[] = merkleTree.getHexProof(merkleTree.leaves[0]);
    console.log(proof)
    try {

      // const tx = await token.claim(formattedAddress, numTokens, proof);
      // await tx.wait(1);
      await syncStatus();
    } catch (e) {
      console.error(`Error when claiming tokens: ${e}`);
    }
  };

  /**
   * After authentication, update number of tokens to claim + claim status
   */
  const syncStatus = async (): Promise<void> => {
    // Toggle loading
    setDataLoading(true);

    // Force authentication
    console.log('ADDRESS HERE ')
    console.log(address)
    if (address) {
      // Collect number of tokens for address
      const tokens = getAirdropAmount(address);
      // possibly edit this so tokens are passed along in proper format to smart contract
      setNumTokens(tokens);
      console.log(tokens);

      // Collect claimed status for address, if part of airdrop (tokens > 0)
      if (tokens > 0) {
        const claimed = await getClaimedStatus(address);
        setAlreadyClaimed(claimed);
      }
    }

    // Toggle loading
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

// Create unstated-next container
export const token = createContainer(useToken);
