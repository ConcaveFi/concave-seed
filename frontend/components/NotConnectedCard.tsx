import React from 'react'
import { Text, Button, Image } from '@chakra-ui/react'
import { useConnect } from 'wagmi'
import colors from 'theme/colors'
import { Card } from 'components/Card'
import { useIsMounted } from 'hooks/useIsMounted'

export const NotConnectedCard = () => {
  const [{ data, error }, connect] = useConnect()
  const isMounted = useIsMounted()
  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
      <Text>Please connect your wallet</Text>
      {isMounted &&
        data.connectors.map((connector) => {
          if (!connector.ready) return null
          // change image from using connector id to something else, injected can be metamask, coinbase, brave etc
          return (
            <Button
              variant="secondary"
              size="large"
              fontSize={24}
              isFullWidth
              leftIcon={<Image maxWidth="20px" src={`/connectors/${connector.id}.png`} alt="" />}
              key={connector.id}
              onClick={() => connect(connector)}
            >
              {connector.name}
            </Button>
          )
        })}
    </Card>
  )
}
