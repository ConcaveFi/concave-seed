import { networkIDtoSymbol } from '@dethcrypto/eth-sdk/dist/abi-management/networks'

export const contracts = {
  mainnet: {
    frax: '0x853d955aCEf822Db058eb8505911ED77F175b99e',
    dai: '0x6b175474e89094c44da98b954eedeac495271d0f',
    pCNV: '0x000000005254e2780df608e16aa29538ee7a9ed9',
  },
  ropsten: {
    frax: '0x853d955aCEf822Db058eb8505911ED77F175b99e',
    dai: '0x6b175474e89094c44da98b954eedeac495271d0f',
    pCNV: '0x000000005254e2780df608e16aa29538ee7a9ed9',
  },
} as const

type InvertResult<T extends Record<PropertyKey, PropertyKey>> = { [P in keyof T as T[P]]: P }
export type AppNetworkId = InvertResult<typeof networkIDtoSymbol>[keyof typeof contracts]

export const networkContracts = (networkId: AppNetworkId) => contracts[networkIDtoSymbol[networkId]]

export default contracts
