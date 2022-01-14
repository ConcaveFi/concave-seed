import React, { useState } from 'react'
import { Button, Image, Text, VStack } from '@chakra-ui/react'
import colors from 'theme/colors'
import { Card } from 'components/Card'
import { useAccount } from 'wagmi'
import { getClaimablePCNVAmount } from 'lib/merkletree'
import ethConfig from 'eth-sdk/config'
import { appNetwork } from 'pages/_app'
import { HOST_URL } from './Meta'
import { networkIDtoSymbol } from '@dethcrypto/eth-sdk/dist/abi-management/networks'

const pCNV = {
  address: ethConfig.contracts[networkIDtoSymbol[appNetwork.id]].pCNV as string,
  image: `${HOST_URL}/assets/tokens/pCNV.png`,
  symbol: 'pCNV',
  decimals: 18,
}

export const AlreadyClaimedCard = () => {
  const [{ data: account }] = useAccount()
  const [error, setError] = useState()
  return account ? (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4} align="center">
      <Image src={pCNV.image} w={128} h={128} mr={2} />
      <VStack spacing={1}>
        <Text>Your {getClaimablePCNVAmount(account.address)}pCNV have been claimed!</Text>
        <Text>Thanks for participating!</Text>
      </VStack>
      <Button
        variant="primary.outline"
        borderRadius="xl"
        onClick={() => account.connector.watchAsset(pCNV).catch(setError)}
      >
        <Image src={pCNV.image} width="32px" height="32px" mr={2} />
        Add pCNV to wallet
      </Button>
      {error && (
        <Text color="text.3" textAlign="center" maxW={233}>
          Looks like your wallet doesn't support token watching
        </Text>
      )}
    </Card>
  ) : null
}
