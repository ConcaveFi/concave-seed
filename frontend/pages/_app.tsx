import { ChakraProvider, cookieStorageManager, localStorageManager } from '@chakra-ui/react'
import type { AppProps } from 'next/app'

import { Provider, chain } from 'wagmi'
import { InjectedConnector } from 'wagmi/connectors/injected'
import { WalletConnectConnector } from 'wagmi/connectors/walletConnect'
import theme from 'theme'
import 'public/fonts.css'
import { providers } from 'ethers'

const infuraId = process.env.NEXT_PUBLIC_INFURA_ID

export const appNetwork = process.env.NODE_ENV === 'development' ? chain.ropsten : chain.mainnet

const connectors = [
  new InjectedConnector({ chains: [appNetwork] }),
  new WalletConnectConnector({
    chains: [appNetwork],
    options: { infuraId, qrcode: true },
  }),
]
const provider = ({ chainId }) => new providers.InfuraProvider(chainId, infuraId)
const webSocketProvider = ({ chainId }) => new providers.InfuraWebSocketProvider(chainId, infuraId)

export default function App({ Component, pageProps }: AppProps) {
  // this ensures the theme will be right even on ssr pages (won't flash wrong theme)
  const colorModeManager =
    typeof pageProps.cookies === 'string'
      ? cookieStorageManager(pageProps.cookies)
      : localStorageManager
  return (
    <ChakraProvider resetCSS theme={theme} colorModeManager={colorModeManager} portalZIndex={100}>
      <Provider
        autoConnect
        connectorStorageKey="concave"
        connectors={connectors}
        provider={provider}
        webSocketProvider={webSocketProvider}
      >
        <Component {...pageProps} />
      </Provider>
    </ChakraProvider>
  )
}

export function getServerSideProps({ req }) {
  return { props: { cookies: req.headers.cookie ?? '' } }
}
