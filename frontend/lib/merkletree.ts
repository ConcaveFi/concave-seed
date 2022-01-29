import { TokenName } from 'eth-sdk/addresses'
import { solidityKeccak256, getAddress, parseUnits } from 'ethers/lib/utils'
import keccak256 from 'keccak256'
import MerkleTree from 'merkletreejs'
import { Tokens } from './tokens'

export const isWhitelisted = (address: string, tokenName: TokenName): boolean =>
  !!Tokens[tokenName].whitelist[getAddress(address)]

export const getMaxStableBuyAmount = (address: string, tokenName: TokenName): number =>
  Tokens[tokenName].whitelist[getAddress(address)]

export const leafOf = (tokenName: TokenName) => (address: string) => {
  const claimableQuantiy = getMaxStableBuyAmount(address, tokenName)
  return Buffer.from(
    solidityKeccak256(
      ['address', 'uint256'],
      [
        getAddress(address), // normalizes to checksum address
        parseUnits(claimableQuantiy.toString(), Tokens[tokenName].decimals).toString(), // parse claimable amount to token decimals
      ],
    ).slice(2),
    'hex',
  )
}

const makeMerkleTree = (tokenName: TokenName) =>
  new MerkleTree(Object.keys(Tokens[tokenName].whitelist).map(leafOf(tokenName)), keccak256, {
    sortPairs: true,
  })

export const MerkleTrees = {
  aCNV: makeMerkleTree('aCNV'),
  bbtCNV: makeMerkleTree('bbtCNV'),
}

console.log('merkle roots', {
  aCNV: MerkleTrees.aCNV.getHexRoot(),
  bbtCNV: MerkleTrees.bbtCNV.getHexRoot(),
})

export default MerkleTrees
