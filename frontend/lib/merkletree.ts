import { ethers } from 'ethers'
import keccak256 from 'keccak256'
import MerkleTree from 'merkletreejs'

const token = {
  decimals: 18,
}

// 0x5bca0297cf0837ede270abe15348e95aa52dfad9531f6431cb24d6d51f1167f0
export const addressClaimableQuantity = {
  '0x507F0daA42b215273B8a063B092ff3b6d27767aF': 1000,
  '0x09E6f1BCb006925B9390cf72c07544018145DC25': 1000,
}

export const isWhitelisted = (address: string): boolean =>
  !!addressClaimableQuantity[ethers.utils.getAddress(address)] || false

export const getClaimablePCNVAmount = (address: string): number =>
  addressClaimableQuantity[ethers.utils.getAddress(address)] || 0

export const leafOf = (address: string) => {
  const claimableQuantiy = getClaimablePCNVAmount(address)
  // console.log(address, claimableQuantiy)
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
