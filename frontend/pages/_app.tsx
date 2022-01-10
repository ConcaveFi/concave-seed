import { ChakraProvider, cookieStorageManager, localStorageManager } from '@chakra-ui/react'
import type { AppProps } from 'next/app'

import { Provider, chain } from 'wagmi'
import { InjectedConnector } from 'wagmi/connectors/injected'
import { WalletConnectConnector } from 'wagmi/connectors/walletConnect'
import theme from 'theme'
import 'public/fonts.css'

const infuraId = process.env.INFURA_ID

const connectors = [
  new InjectedConnector({ chains: [chain.mainnet] }),
  new WalletConnectConnector({
    chains: [chain.mainnet],
    options: { infuraId, qrcode: true },
  }),
]

export default function App({ Component, pageProps }: AppProps) {
  // this ensures the theme will be right even on ssr pages (won't flash wrong theme)
  const colorModeManager =
    typeof pageProps.cookies === 'string'
      ? cookieStorageManager(pageProps.cookies)
      : localStorageManager
  return (
    <ChakraProvider resetCSS theme={theme} colorModeManager={colorModeManager} portalZIndex={100}>
      <Provider autoConnect connectorStorageKey="concave.seed" connectors={connectors}>
        <Component {...pageProps} />
      </Provider>
    </ChakraProvider>
  )
}

export function getServerSideProps({ req }) {
  return { props: { cookies: req.headers.cookie ?? '' } }
}
