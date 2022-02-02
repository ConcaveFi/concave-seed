import React, { useState } from 'react'
import { Button, Image, Text, VStack } from '@chakra-ui/react'
import colors from 'theme/colors'
import { Card } from 'components/Card'
import { useAccount } from 'wagmi'
import { Tokens } from 'lib/tokens'

export const AlreadyClaimedCard = ({ tokenName, amountClaimed }) => {
  const [{ data: account }] = useAccount({ fetchEns: false })
  const [error, setError] = useState()
  return account ? (
    <Card
      shadow="up"
      bgGradient={colors.gradients.green}
      px={10}
      py={8}
      gap={4}
      align="center"
      w={410}
    >
      <Image src={Tokens[tokenName].image} w={128} h={128} mr={2} alt="" />
      <VStack spacing={1}>
        <Text>
          Your ${amountClaimed} worth of {tokenName} have been claimed!
        </Text>
        <Text>Thanks for participating! WAGMI</Text>
      </VStack>
      <Button
        variant="primary.outline"
        borderRadius="xl"
        onClick={() => account.connector.watchAsset(Tokens[tokenName]).catch(setError)}
      >
        <Image src={Tokens[tokenName].image} width="32px" height="32px" mr={2} alt="pCNV icon" />
        Add {tokenName} to wallet
      </Button>
      {error && (
        <Text color="text.3" textAlign="center" maxW={233}>
          {`Looks like your wallet doesn't support token watching`}
        </Text>
      )}
    </Card>
  ) : null
}
