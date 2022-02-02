import { addresses } from 'eth-sdk/addresses'
import { appNetwork } from 'components/wagmi/WagmiProvider'
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
    image: `https://concave-seed.vercel.app/assets/tokens/pCNV.png`,
  },
  bbtCNV: {
    decimals: 18,
    whitelist: normalizeWhitelist(bbtCNVWhitelist),
    price: 10,
    address: addresses[appNetwork.id].bbtCNV,
    symbol: 'bbtCNV',
    image: `https://concave-seed.vercel.app/assets/tokens/pCNV.png`,
  },
}
