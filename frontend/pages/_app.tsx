import { ChakraProvider, cookieStorageManager, localStorageManager } from '@chakra-ui/react'
import type { AppProps } from 'next/app'

import { chain } from 'wagmi'
import theme from 'theme'
import 'public/fonts.css'
import { WagmiProvider } from 'components/wagmi/WagmiProvider'

export const appNetwork =
  process.env.NEXT_PUBLIC_VERCEL_ENV !== 'production' ? chain.ropsten : chain.mainnet

export default function App({ Component, pageProps }: AppProps) {
  // this ensures the theme will be right even on ssr pages (won't flash wrong theme)
  const colorModeManager =
    typeof pageProps.cookies === 'string'
      ? cookieStorageManager(pageProps.cookies)
      : localStorageManager
  return (
    <ChakraProvider resetCSS theme={theme} colorModeManager={colorModeManager} portalZIndex={100}>
      <WagmiProvider>
        <Component {...pageProps} />
      </WagmiProvider>
    </ChakraProvider>
  )
}

export function getServerSideProps({ req }) {
  return { props: { cookies: req.headers.cookie ?? '' } }
}
