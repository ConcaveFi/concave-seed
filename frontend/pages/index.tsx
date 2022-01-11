import { Box, Heading, Text, Flex, Container, Spinner } from '@chakra-ui/react'
import React, { useEffect, useState } from 'react'
import { Layout } from '../components/Layout'
import { useAccount, useNetwork } from 'wagmi'
import { getClaimablePCNVAmount, isWhitelisted } from 'lib/merkletree'
import { WrongNetworkCard } from 'components/WrongNetwork'
import { NotConnectedCard } from 'components/NotConnectedCard'
import { ClaimCard } from 'components/ClaimCard'
import { NotWhitelistedCard } from 'components/NotWhitelistedCard'
import { appNetwork } from './_app'
import { getUserClaimablePCNVAmount } from 'lib/claim'
import { useSigner } from 'hooks/useSigner'
import { BigNumber } from 'ethers'
import { useUserClaimableAmount } from 'hooks/useUserClaimableAmount'
import { AlreadyClaimedCard } from 'components/AlreadyClaimedCard'

type AppState =
  | 'loading'
  | 'wrong_network'
  | 'not_connected'
  | 'not_whitelisted'
  | 'already_claimed'
  | 'claiming'

function CNVSeed() {
  const [{ data: network }] = useNetwork()
  const [{ data: account }] = useAccount()
  const [{ data: signer }] = useSigner()

  const [state, setState] = useState<AppState>('loading')

  useEffect(() => {
    setState('loading')
    if (!account || !network || !signer) return
    ;(async () => {
      if (network?.chain?.unsupported) return 'wrong_network'
      if (!account?.address) return 'not_connected'
      if (!isWhitelisted(account.address)) return 'not_whitelisted'
      if ((await getUserClaimablePCNVAmount(signer)).eq(0)) return 'already_claimed'
      return 'claiming'
    })().then(setState)
  }, [account, network, signer])

  return (
    <Layout>
      <Container maxW="container.md">
        <Flex direction="column" gap={12}>
          <Box mt={12}>
            <Heading as="h1">Sacrificial Spoon Offering Receptacle</Heading>
            <Text maxW={520}>Speak softly but carry a big spoon</Text>
          </Box>
          <Flex gap={6} flexWrap="wrap" justify="center">
            {state === 'loading' && <Spinner />}
            {state === 'wrong_network' && <WrongNetworkCard supportedNetwork={appNetwork} />}
            {state === 'not_connected' && <NotConnectedCard />}
            {state === 'not_whitelisted' && <NotWhitelistedCard />}
            {state === 'already_claimed' && <AlreadyClaimedCard />}
            {state === 'claiming' && <ClaimCard />}
          </Flex>
        </Flex>
      </Container>
    </Layout>
  )
}

export default CNVSeed
