import React from 'react'
import { Button, Image, Text } from '@chakra-ui/react'
import colors from 'theme/colors'
import { Card } from 'components/Card'
import { useAccount } from 'wagmi'
import { getClaimablePCNVAmount } from 'lib/merkletree'
import ethConfig from 'eth-sdk.config'
import { appNetwork } from 'pages/_app'

const pCNV = {
  address: ethConfig.contracts[appNetwork.id],
  image: '/assets/tokens/eth.svg', // tritonnn
  symbol: 'pCNV',
}

export const AlreadyClaimedCard = () => {
  const [{ data: account }] = useAccount()
  return account ? (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4} textAlign="center">
      <Text>Your {getClaimablePCNVAmount(account.address)}pCNV have been claimed!</Text>
      <Text>Thanks for participating!</Text>
      <Button borderRadius="xl" onClick={() => account.connector.watchAsset(pCNV)}>
        <Image src={pCNV.image} width="24px" height="24px" mr={2} />
        Add pCNV to wallet
      </Button>
    </Card>
  ) : null
}
