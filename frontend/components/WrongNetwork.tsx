import React from 'react'
import { Text, Button } from '@chakra-ui/react'
import { chain } from 'wagmi'
import colors from 'theme/colors'
import { Card } from 'components/Card'

export const WrongNetworkCard = ({ switchNetwork }) => {
  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
      <Text>lol u not on eth bro</Text>
      <Button
        onClick={() => switchNetwork(chain.mainnet.id)}
        variant="primary"
        size="large"
        fontSize={24}
        isFullWidth
      >
        Switch to Ethereum
      </Button>
    </Card>
  )
}
