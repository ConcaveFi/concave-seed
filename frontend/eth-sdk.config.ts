import { defineConfig } from '@dethcrypto/eth-sdk'

export default defineConfig({
  contracts: {
    mainnet: {
      frax: '0x853d955aCEf822Db058eb8505911ED77F175b99e',
      dai: '0x6b175474e89094c44da98b954eedeac495271d0f',
    },
    ropsten: {
      frax: '0xE7E9F348202f6EDfFF2607025820beE92F51cdAA',
      dai: '0x7B731FFcf1b9C6E0868dA3F1312673A12Da28dc5',
      pCNV: '0xd496ca8cb080e00539219cdf601521b733ec5eab',
    },
  },
})
