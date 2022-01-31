import { Provider, defaultChains } from 'wagmi'
import { InjectedConnector } from 'wagmi/connectors/injected'
import { WalletConnectConnector } from 'wagmi/connectors/walletConnect'
import { providers } from 'ethers'
import { appNetwork } from 'pages/_app'
import { ReactChild, ReactChildren } from 'react'

const alchemy = process.env.NEXT_PUBLIC_ALCHEMY_ID as string
const etherscan = process.env.NEXT_PUBLIC_ETHERSCAN_API_KEY as string
const infuraId = process.env.NEXT_PUBLIC_INFURA_ID as string

const connectors = [
  new InjectedConnector({ chains: [appNetwork] }),
  new WalletConnectConnector({
    chains: [appNetwork],
    options: { infuraId, qrcode: true },
  }),
]

const isChainSupported = (chainId?: number) => defaultChains.some((x) => x.id === chainId)

const provider = ({ chainId }) =>
  providers.getDefaultProvider(isChainSupported(chainId) ? chainId : appNetwork, {
    alchemy,
    etherscan,
    infuraId,
  })
const webSocketProvider = ({ chainId }) =>
  new providers.InfuraWebSocketProvider(isChainSupported(chainId) ? chainId : appNetwork, infuraId)

export const WagmiProvider = ({ children }: { children: ReactChild }) => (
  <Provider
    autoConnect
    connectorStorageKey="concave"
    connectors={connectors}
    provider={provider}
    webSocketProvider={webSocketProvider}
  >
    {children}
  </Provider>
)
