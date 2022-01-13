import React, { useEffect, useState } from 'react'
import { Button } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import { AmountInput } from './Input'
import { inputTokens, claim } from 'lib/claim'
import { getClaimablePCNVAmount } from 'lib/merkletree'
import { useSigner } from '../hooks/useSigner'

export function ClaimCard({ maxAmount }) {
  const [amount, setAmount] = useState('0')
  const [inputToken, setInputToken] = useState(inputTokens[0])

  const [isLoading, setIsLoading] = useState(false)

  const [{ data: signer }] = useSigner()	
  useEffect(() => {	
    if (signer)	
      getClaimablePCNVAmount(signer)
  }, [signer])
  const onClaim = async () => {
    setIsLoading(true)
    await claim(await account.connector.getSigner(), amount, inputToken).finally(() =>
      setIsLoading(false),
    )
  }
  const claimPCNV = async () => {
    setIsLoading(true)
    const signer = await account.connector.getSigner()
    try {
      await claim(signer, amount, inputToken)
    } catch (e) {
      console.log(e)
      // setError()
      setIsLoading(false)
    }
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
