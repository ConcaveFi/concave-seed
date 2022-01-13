import React, { useEffect, useState } from 'react'
import { Button } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import { AmountInput } from './Input'
import { claim, getUserClaimablePCNVAmount, inputTokens, pCNVSeedPrice } from 'lib/claim'
import { useAccount } from 'wagmi'
import { useSigner } from 'hooks/useSigner'

export function ClaimCard() {
  const [amount, setAmount] = useState('0')
  const [inputToken, setInputToken] = useState(inputTokens[0])

  const [isLoading, setIsLoading] = useState(false)

  const [{ data: account }] = useAccount()

  const [{ data: signer }] = useSigner()
  const [claimableAmount, setClaimableAmount] = useState(0)
  useEffect(() => {
    if (signer)
    console.log('test')
      getUserClaimablePCNVAmount(signer)
        .then((a) => setClaimableAmount(a.toNumber()))
        .catch(console.log)
  }, [signer])

  const onClaim = async () => {
    setIsLoading(true)
    await claim(await account.connector.getSigner(), amount, inputToken).finally(() =>
      setIsLoading(false),
    )
  }

  return (
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
