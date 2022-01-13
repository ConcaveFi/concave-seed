import fs from "fs"; // Filesystem
import path from "path"; // Path
import keccak256 from "keccak256"; // Keccak256 hashing
import MerkleTree from "merkletreejs"; // MerkleTree.js
import { logger } from "./utils/logger"; // Logging
import { getAddress, parseUnits, solidityKeccak256 } from "ethers/lib/utils"; // Ethers utils

// Output file path
const outputPath: string = path.join(__dirname, "../merkle.json");

// Airdrop recipient addresses and scaled token values
type AirdropRecipient = {
  // Recipient address
  address: string;
  // Scaled-to-decimals token value
  value: string;
};

export default class Generator {
  // Airdrop recipients
  recipients: AirdropRecipient[] = [];

  /**
   * Setup generator
   * @param {number} decimals of token
   * @param {Record<string, number>} airdrop address to token claim mapping
   */
  constructor(decimals: number, airdrop: Record<string, number>) {
    // For each airdrop entry
    let total = 0;
    const amounts: any = [];
    for (const [address, tokens] of Object.entries(airdrop)) {
      // Push:
      total += tokens;
      amounts.push(tokens);
      this.recipients.push({
        // Checksum address
        address: getAddress(address),
        // Scaled number of tokens claimable by recipient
        value: parseUnits(tokens.toString(), decimals).toString()
      });
    }
    console.log(total);
    console.log(amounts);
  }

  /**
   * Generate Merkle Tree leaf from address and value
   * @param {string} address of airdrop claimee
   * @param {string} value of airdrop tokens to claimee
   * @returns {Buffer} Merkle Tree node
   */
  generateLeaf(address: string, value: string): Buffer {
    return Buffer.from(
      // Hash in appropriate Merkle format
      solidityKeccak256(["address", "uint256"], [address, value]).slice(2),
      "hex"
    );
  }

  async process(): Promise<void> {
    logger.info("Generating Merkle tree.");

    const addys: any = [];
    const proofs: any = [];

    let merkleLeaf: string[];
    // Generate merkle tree
    const merkleTree = new MerkleTree(
      // Generate leafs
      this.recipients.map(({ address, value }) => {
        // console.log(getAddress(address));
        // console.log(this.generateLeaf(address, value).toString('hex'));
        addys.push(getAddress(address));
        proofs.push(this.generateLeaf(address, value).toString("hex"));
        return this.generateLeaf(address, value);
      }),
      // Hashing function
      keccak256,
      { sortPairs: true }
    );

    console.log(addys);
    console.log(proofs);
    console.log(addys.length);
    const pppp: any = [];
    for (let index = 0; index < proofs.length; index++) {
      // const element = array[index];
      pppp.push(
        merkleTree
          .getProof(proofs[index])
          .map((d: any) => d.data.toString("hex"))
        //.map(d => [...d.map((d:any) => d.data)])
      );
    }
    for (let index = 0; index < pppp.length; index++) {
      if (pppp[index].length < 7) {
        for (let i = 0; i < pppp[i].length - 7; i++) {
          pppp[i].push("0x0");
        }
      }
    }
    console.log(pppp);

    await fs.writeFileSync(
      // Output to merkle.json
      "proofs.json",
      // Root + full tree
      JSON.stringify(pppp)
    );

    // Collect and log merkle root
    const merkleRoot: string = merkleTree.getHexRoot();
    logger.info(`Generated Merkle root: ${merkleRoot}`);

    // Collect and save merkle tree + root
    await fs.writeFileSync(
      // Output to merkle.json
      outputPath,
      // Root + full tree
      JSON.stringify({
        root: merkleRoot,
        tree: merkleTree
      })
    );
    logger.info("Generated merkle tree and root saved to Merkle.json.");
  }
}
