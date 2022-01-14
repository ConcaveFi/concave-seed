import React, { useCallback, useEffect, useState } from 'react'
import { Button, Link, Stack, Text } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import { AmountInput } from './Input'
import { claim, getUserClaimablePCNVAmount, inputTokens } from 'lib/claim'

export function ClaimCard({ signer, afterSuccessfulClaim }) {
  const [amount, setAmount] = useState('0')
  const [inputToken, setInputToken] = useState(inputTokens[0])

  const [isLoading, setIsLoading] = useState(false)

  const [claimableAmount, setClaimableAmount] = useState(0)

  const syncUserClaimableAmount = useCallback(() => {
    if (signer) getUserClaimablePCNVAmount(signer).then(setClaimableAmount).catch(console.log)
  }, [signer])

  useEffect(() => {
    if (signer) syncUserClaimableAmount()
  }, [signer])

  const onClaim = async () => {
    setIsLoading(true)
    await claim(signer, amount, inputToken)
      .then(() => {
        syncUserClaimableAmount()
        setAmount('0')
        afterSuccessfulClaim()
      })
      .finally(() => setIsLoading(false))
  }

  return (
    <Stack spacing={3} align="center">
      <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
        <AmountInput
          maxAmount={claimableAmount}
          value={amount}
          onChangeValue={setAmount}
          tokenOptions={inputTokens}
          selectedToken={inputToken}
          onSelectToken={setInputToken}
        />
        <Button
          onClick={onClaim}
          isLoading={!signer || isLoading}
          isDisabled={!signer || Number(amount) < 1}
          variant="primary"
          size="large"
          fontSize={24}
          isFullWidth
        >
          Claim pCNV
        </Button>
      </Card>
      <Text fontSize="sm" color="text.3" maxW={400} textAlign="center">
        Feel free to ping us in{' '}
        <Link color="text.highlight" href="https://discord.gg/tB3tPby3">
          discord
        </Link>{' '}
        if you need help claiming using a multisig
      </Text>
    </Stack>
  )
}
