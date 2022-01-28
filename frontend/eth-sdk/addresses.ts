import { NetworkID } from '@dethcrypto/eth-sdk/dist/abi-management/networks'

export const addresses = {
  [NetworkID.MAINNET]: {
    frax: '0x853d955aCEf822Db058eb8505911ED77F175b99e',
    dai: '0x6b175474e89094c44da98b954eedeac495271d0f',
    bbtCNV: '0xc32baea7792bf39b8b89fa33a108d2064db43ee5',
    cCNV: '0x6c64efbbaea3ebec73588a8e20cf058344f5f1cf',
  },
  [NetworkID.ROPSTEN]: {
    frax: '0xE7E9F348202f6EDfFF2607025820beE92F51cdAA',
    dai: '0x7B731FFcf1b9C6E0868dA3F1312673A12Da28dc5',
    bbtCNV: '0xc32baea7792bf39b8b89fa33a108d2064db43ee5',
    cCNV: '0x6c64efbbaea3ebec73588a8e20cf058344f5f1cf',
  },
}

export type TokenName = keyof typeof addresses[keyof typeof addresses]