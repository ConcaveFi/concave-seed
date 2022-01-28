import { addresses } from 'eth-sdk/addresses'
import { appNetwork } from 'pages/_app'
import bbtCNVWhitelist from './bbtCNV_whitelist.json'
import cCNVWhitelist from './cCNV_whitelist.json'

export const Tokens = {
  cCNV: {
    decimals: 18,
    whitelist: cCNVWhitelist,
    price: 10,
    address: addresses[appNetwork.id].cCNV,
    symbol: 'cCNV',
    image: `/seed/assets/tokens/pCNV.png`,
  },
  bbtCNV: {
    decimals: 18,
    whitelist: bbtCNVWhitelist,
    price: 50,
    address: addresses[appNetwork.id].bbtCNV,
    symbol: 'bbtCNV',
    image: `/seed/assets/tokens/pCNV.png`,
  },
}
