import { NetworkID } from '@dethcrypto/eth-sdk/dist/abi-management/networks'

export const addresses = {
  [NetworkID.MAINNET]: {
    frax: '0x853d955aCEf822Db058eb8505911ED77F175b99e',
    dai: '0x6b175474e89094c44da98b954eedeac495271d0f',
    bbtCNV: '0x000000005254e2780df608e16aa29538ee7a9ed9',
    cCNV: '0xa0fed11f114ae39bd7872d8dc9267a67a2d79ecd',
  },
  [NetworkID.ROPSTEN]: {
    frax: '0xE7E9F348202f6EDfFF2607025820beE92F51cdAA',
    dai: '0x7B731FFcf1b9C6E0868dA3F1312673A12Da28dc5',
    bbtCNV: '0xa0fed11f114ae39bd7872d8dc9267a67a2d79ecd',
    cCNV: '0xa0fed11f114ae39bd7872d8dc9267a67a2d79ecd',
  },
}

export type TokenName = keyof typeof addresses[keyof typeof addresses]
