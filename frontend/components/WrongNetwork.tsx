import React from 'react'
import { Text, Button } from '@chakra-ui/react'
import { Chain, useNetwork } from 'wagmi'
import colors from 'theme/colors'
import { Card } from 'components/Card'

export const WrongNetworkCard = ({ supportedNetwork }: { supportedNetwork: Chain }) => {
  const [{ data: currentNetwork }, switchNetwork] = useNetwork()
  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
      <Text>{`You're connected to ${currentNetwork.chain.name}`}</Text>
      <Button
        onClick={() => switchNetwork(supportedNetwork.id)}
        variant="primary"
        size="large"
        fontSize={24}
        isFullWidth
      >
        Switch to {supportedNetwork.name}
      </Button>
    </Card>
  )
}
