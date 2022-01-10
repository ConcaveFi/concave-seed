import React from 'react'
import { Text, Button, Image } from '@chakra-ui/react'
import { useConnect } from 'wagmi'
import colors from 'theme/colors'
import { Card } from 'components/Card'

export const NotConnectedCard = () => {
  const [{ data, error }, connect] = useConnect()
  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
      <Text>please connect your wallet</Text>
      {data.connectors.map((connector) => (
        <Button
          variant="secondary"
          size="large"
          fontSize={24}
          isFullWidth
          leftIcon={<Image maxWidth="20px" src={`/connectors/${connector.name}.png`} alt="" />}
          key={connector.id}
          onClick={() => connect(connector)}
        >
          {connector.name}
        </Button>
      ))}
    </Card>
  )
}
