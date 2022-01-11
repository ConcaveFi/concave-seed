import { Box, Heading, Text, Flex, Container } from '@chakra-ui/react'
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

type AppState =
  | 'loading'
  | 'wrong_network'
  | 'not_connected'
  | 'not_whitelisted'
  | 'already_claimed'
  | 'claiming'

const resolveState = async (
  isConnectedNetworkSupported,
  userAddress,
  userClaimableAmount: BigNumber,
): Promise<AppState> => {
  if (isConnectedNetworkSupported) return 'wrong_network'
  if (!userAddress) return 'not_connected'
  if (!isWhitelisted(userAddress)) return 'not_whitelisted'
  if (userClaimableAmount.eq(0)) return 'already_claimed'
  return 'claiming'
}

function CNVSeed() {
  const [{ data: network, loading: networkLoading }] = useNetwork()
  const [{ data: account, loading: accountLoading }] = useAccount()

  const [state, setState] = useState<AppState>('loading')
  const [{ data: userClaimableAmount, loading: userClaimableAmountLoading }] =
    useUserClaimableAmount()

  useEffect(() => {
    setState('loading')
    if (accountLoading || networkLoading || userClaimableAmountLoading) return
    resolveState(network.chain.unsupported, account.address, userClaimableAmount).then(setState)
  }, [network?.chain?.unsupported, account?.address, userClaimableAmount])

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
