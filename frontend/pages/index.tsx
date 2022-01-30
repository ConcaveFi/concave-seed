import { Flex, Container, Spinner } from '@chakra-ui/react'
import React, { useCallback, useEffect, useState } from 'react'
import { Layout } from '../components/Layout'
import { useAccount, useNetwork } from 'wagmi'
import { isWhitelisted } from 'lib/merkletree'
import { WrongNetworkCard } from 'components/WrongNetwork'
import { NotConnectedCard } from 'components/NotConnectedCard'
import { ClaimCard } from 'components/ClaimCard'
import { NotWhitelistedCard } from 'components/NotWhitelistedCard'
import { appNetwork } from './_app'

type AppState = 'loading' | 'wrong_network' | 'not_connected' | 'not_whitelisted' | 'claiming'

function CNVSeed() {
  const [{ data: network, loading: networkLoading }] = useNetwork()
  const [{ data: account, loading: accountLoading }] = useAccount({ fetchEns: false })

  const [state, setState] = useState<AppState>('loading')

  const syncState = useCallback(() => {
    ;(async () => {
      if (accountLoading || networkLoading) return 'loading'
      if (network?.chain?.unsupported) return 'wrong_network'
      if (!account?.address) return 'not_connected'
      if (!isWhitelisted(account.address, 'bbtCNV') && !isWhitelisted(account.address, 'aCNV'))
        return 'not_whitelisted'
      return 'claiming'
    })().then(setState)
  }, [account?.address, accountLoading, network?.chain?.unsupported, networkLoading])

  useEffect(() => syncState(), [syncState])

  return (
    <Layout>
      <Container maxW="container.md">
        <Flex direction="column" gap={12}>
          <Flex gap={6} flexWrap="wrap" justify="center">
            {state === 'loading' && <Spinner />}
            {state === 'wrong_network' && <WrongNetworkCard supportedNetwork={appNetwork} />}
            {state === 'not_connected' && <NotConnectedCard />}
            {state === 'not_whitelisted' && <NotWhitelistedCard />}
            {state === 'claiming' && <ClaimCard userAddress={account.address} />}
          </Flex>
        </Flex>
      </Container>
    </Layout>
  )
}

export default CNVSeed
