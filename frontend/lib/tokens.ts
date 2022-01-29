import { addresses } from 'eth-sdk/addresses'
import { appNetwork } from 'pages/_app'
import bbtCNVWhitelist from './bbtCNV_whitelist.json'
import aCNVWhitelist from './aCNV_whitelist.json'
import { getAddress } from 'ethers/lib/utils'

const normalizeWhitelist = (whitelist) =>
  Object.entries(whitelist).reduce(
    (acc, [address, amount]) => ({
      ...acc,
      [getAddress(address)]: amount,
    }),
    {},
  )

export const Tokens = {
  aCNV: {
    decimals: 18,
    whitelist: normalizeWhitelist(aCNVWhitelist),
    price: 50,
    address: addresses[appNetwork.id].aCNV,
    symbol: 'aCNV',
    image: `/seed/assets/tokens/pCNV.png`,
  },
  bbtCNV: {
    decimals: 18,
    whitelist: normalizeWhitelist(bbtCNVWhitelist),
    price: 10,
    address: addresses[appNetwork.id].bbtCNV,
    symbol: 'bbtCNV',
    image: `/seed/assets/tokens/pCNV.png`,
  },
}
