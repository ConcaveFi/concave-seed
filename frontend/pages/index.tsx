import { Box, Heading, Text, Flex, Container, Button, Image, Spinner } from '@chakra-ui/react'
import React, { useEffect, useState } from 'react'
import { Layout } from '../components/Layout'
import { chain, useAccount, useConnect, useNetwork } from 'wagmi'
import { getClaimableAmount } from 'lib/merkletree'
import colors from 'theme/colors'
import { Card } from 'components/Card'
import { WrongNetworkCard } from 'components/WrongNetwork'
import { NotConnectedCard } from 'components/NotConnectedCard'
import { ClaimCard } from 'components/ClaimCard'
import { NotWhitelistedCard } from 'components/NotWhitelistedCard'

type AppState =
  | 'loading'
  | 'wrong_network'
  | 'not_connected'
  | 'not_whitelisted'
  | 'already_claimed'
  | 'claiming'

const resolveState = (network, account): AppState => {
  if (network?.chain?.unsupported) return 'wrong_network'
  if (!account?.address) return 'not_connected'
  if (getClaimableAmount(account.address) === 0) return 'not_whitelisted'
  if (false) return 'already_claimed'
  return 'claiming'
}

function CNVSeed() {
  const [{ data: network, loading: networkLoading }, switchNetwork] = useNetwork()
  const [{ data: account, loading: accountLoading }] = useAccount()

  const [state, setState] = useState<AppState>('loading')

  useEffect(() => {
    if (accountLoading || networkLoading) return
    setState(resolveState(network, account))
  }, [account?.address, network?.chain?.id])

  return (
    <Layout>
      <Container maxW="container.md">
        <Flex direction="column" gap={12}>
          <Box mt={12}>
            <Heading as="h1">Sacrificial Spoon Offering Receptacle</Heading>
            <Text maxW={520}>Speak softly but carry a big spoon</Text>
          </Box>
          <Flex gap={6} flexWrap="wrap" justify="center">
            {/* {state === 'loading' && <Spinner />} */}
            {state === 'wrong_network' && <WrongNetworkCard switchNetwork={switchNetwork} />}
            {state === 'not_connected' && <NotConnectedCard />}
            {state === 'not_whitelisted' && <NotWhitelistedCard />}
            {state === 'claiming' && <ClaimCard />}
          </Flex>
        </Flex>
      </Container>
    </Layout>
  )
}

export default CNVSeed
