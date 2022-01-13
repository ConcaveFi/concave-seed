import React from 'react'
import { Text } from '@chakra-ui/react'
import colors from 'theme/colors'
import { Card } from 'components/Card'
import { useAccount } from 'wagmi'
import { getClaimablePCNVAmount } from 'lib/merkletree'

export const AlreadyClaimedCard = () => {
  const [{ data: account }] = useAccount()
  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4} textAlign="center">
      <Text>Your {getClaimablePCNVAmount(account.address)} pCNV have been claimed!</Text>
      <Text>Thanks for participating!</Text>
      <Text>WAGMI</Text>
    </Card>
  )
}
