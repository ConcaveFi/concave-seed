import React from 'react'
import { Text } from '@chakra-ui/react'
import colors from 'theme/colors'
import { Card } from 'components/Card'

export const NotWhitelistedCard = () => {
  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
      <Text>This wallet is not whitelisted</Text>
    </Card>
  )
}
