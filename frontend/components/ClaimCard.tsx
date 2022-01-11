import React, { useState } from 'react'
import { Button, useQuery } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import { AmountInput } from './Input'
import { claim, inputTokens } from 'lib/claim'
import { useAccount, useContractRead } from 'wagmi'
import { useUserClaimableAmount } from 'hooks/useUserClaimableAmount'

export function ClaimCard() {
  const [amount, setAmount] = useState('0')
  const [inputToken, setInputToken] = useState(inputTokens[0])

  const [isLoading, setIsLoading] = useState(false)

  const [{ data: account }] = useAccount()
  const [{ data: maxAmount }] = useUserClaimableAmount()

  const onClaim = async () => {
    setIsLoading(true)
    await claim(await account.connector.getSigner(), amount, inputToken).finally(() =>
      setIsLoading(false),
    )
  }

  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
      <AmountInput
        maxAmount={maxAmount}
        value={amount}
        onChangeValue={setAmount}
        tokenOptions={inputTokens}
        selectedToken={inputToken}
        onSelectToken={setInputToken}
      />
      <Button
        onClick={onClaim}
        isLoading={isLoading}
        isDisabled={Number(amount) < 1}
        variant="primary"
        size="large"
        fontSize={24}
        isFullWidth
      >
        Claim pCNV
      </Button>
    </Card>
  )
}
