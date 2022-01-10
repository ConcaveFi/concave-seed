import { defineConfig } from '@dethcrypto/eth-sdk'

export default defineConfig({
  contracts: {
    mainnet: {
      frax: '0x853d955aCEf822Db058eb8505911ED77F175b99e',
      dai: '0x6b175474e89094c44da98b954eedeac495271d0f',
    },
    ropsten: {
      frax: '0x3C0a7EC8c962A85bfB1e4FcfD4bB71C8128dE6f7',
      dai: '0x448C56C5eA442908238072eFb7f5Ce58E22C161C',
      pCNV: '0xb6308694bfc72a558cd349c8878877524915e652',
    },
  },
})
