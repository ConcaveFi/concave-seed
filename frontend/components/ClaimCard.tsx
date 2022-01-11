import React, { useState } from 'react'
import { Button } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import { AmountInput } from './Input'
import { inputTokens, claim } from 'lib/claim'
import { useAccount, useProvider } from 'wagmi'

export function ClaimCard({ maxAmount }) {
  const [amount, setAmount] = useState('0')
  const [inputToken, setInputToken] = useState(inputTokens[0])

  const [{ data: account }] = useAccount()

  const [isLoading, setIsLoading] = useState(false)

  const claimPCNV = async () => {
    setIsLoading(true)
    const signer = await account.connector.getSigner()
    await claim(account.address, signer, amount, inputToken)
    setIsLoading(false)
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
        onClick={claimPCNV}
        isLoading={isLoading}
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
