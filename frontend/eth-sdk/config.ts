import { defineConfig } from '@dethcrypto/eth-sdk'
import { networkIDtoSymbol } from '@dethcrypto/eth-sdk/dist/abi-management/networks'
import { addresses } from './addresses'

const config = defineConfig({
  contracts: Object.entries(addresses).reduce(
    (acc, [n, a]) => ({ ...acc, [networkIDtoSymbol[n]]: a }),
    {},
  ),
})

export default config
