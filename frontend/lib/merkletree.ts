import { ethers } from 'ethers'
import keccak256 from 'keccak256'
import MerkleTree from 'merkletreejs'

const token = {
  decimals: 18,
}

export const addressClaimableQuantity = {
  '0x016C8780e5ccB32E5CAA342a926794cE64d9C364': 10,
  '0x109f93893af4c4b0afc7a9e97b59991260f98313': 100,
  '0x09E6f1BCb006925B9390cf72c07544018145DC25': 100,
  '0x507F0daA42b215273B8a063B092ff3b6d27767aF': 100,
}

export const getClaimableAmount = (address: string): number =>
  addressClaimableQuantity[ethers.utils.getAddress(address)] || 0

export const leafOf = (address: string) => {
  const claimableQuantiy = getClaimableAmount(address)
  return Buffer.from(
    ethers.utils
      .solidityKeccak256(
        ['address', 'uint256'],
        [
          ethers.utils.getAddress(address), // normalizes to checksum address
          ethers.utils.parseUnits(claimableQuantiy.toString(), token.decimals).toString(), // parse claimable amount to token decimals
        ],
      )
      .slice(2),
    'hex',
  )
}

export const merkleTree = new MerkleTree(
  Object.keys(addressClaimableQuantity).map(leafOf),
  keccak256,
  { sortPairs: true },
)

export default merkleTree
