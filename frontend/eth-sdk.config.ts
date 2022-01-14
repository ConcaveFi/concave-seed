import { defineConfig } from '@dethcrypto/eth-sdk'

export default defineConfig({
  contracts: {
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
  },
})