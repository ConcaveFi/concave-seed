import { ethers } from 'ethers'
import keccak256 from 'keccak256'
import MerkleTree from 'merkletreejs'

const token = {
  decimals: 18,
}

export const addressClaimableQuantity = {
  "0xFb882cF1f72a2887d7E1a60207e3dE592c08ce10": 1000
}

// 0xc2ad4a403668a2f5a60f95ef6b6b94e684372139
// 0x2aa48f410007b7380d2846d03142febbbedeb3d3
// 0x9ead5e6e90440e69b5f28fef5942a5b273387c13

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
