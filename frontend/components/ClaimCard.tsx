import React, { useState } from 'react'
import { Button } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import { AmountInput } from './Input'

const inputTokenOptions = ['dai', 'frax']

export function ClaimCard() {
  const [amount, setAmount] = useState('0')
  const [inputToken, setInputToken] = useState(inputTokenOptions[0])

  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
      <AmountInput
        maxAmount={500000}
        value={amount}
        onChangeValue={setAmount}
        tokenOptions={inputTokenOptions}
        selectedToken={inputToken}
        onSelectToken={setInputToken}
      />
      <Button variant="primary" size="large" fontSize={24} isFullWidth>
        Claim pCNV
      </Button>
    </Card>
  )
}
