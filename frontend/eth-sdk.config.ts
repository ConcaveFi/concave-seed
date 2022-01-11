import { defineConfig } from '@dethcrypto/eth-sdk'

export default defineConfig({
  contracts: {
    mainnet: {
      frax: '0x853d955aCEf822Db058eb8505911ED77F175b99e',
      dai: '0x6b175474e89094c44da98b954eedeac495271d0f',
      pCNV: '0xa0Fed11F114Ae39Bd7872D8Dc9267a67A2D79eCD',
    },
    ropsten: {
      frax: '0xE7E9F348202f6EDfFF2607025820beE92F51cdAA',
      dai: '0x7B731FFcf1b9C6E0868dA3F1312673A12Da28dc5',
      pCNV: '0xa0Fed11F114Ae39Bd7872D8Dc9267a67A2D79eCD',
    },
  },
})
