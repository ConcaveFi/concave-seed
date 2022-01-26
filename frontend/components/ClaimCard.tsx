import React, { useCallback, useEffect, useState } from 'react'
import { Button, Link, Stack, Text } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import { AmountInput } from './Input'
import { claim, getUserClaimablePCNVAmount, inputTokens } from 'lib/claim'
import { useAccount, useContractRead, useContractWrite } from 'wagmi'
import { appNetwork } from 'pages/_app'
import { addresses, TokenName } from 'eth-sdk/addresses'
import erc20Abi from 'eth-sdk/abis/erc20.json'

const useAllowance = (allowed: TokenName, spender: TokenName) => {
  const [account] = useAccount()
  console.log(addresses[appNetwork.id][allowed])
  const [allowance, fetchAllowance] = useContractRead(
    { addressOrName: addresses[appNetwork.id][allowed], contractInterface: erc20Abi },
    'allowance',
    { skip: true, watch: true },
  )

  useEffect(() => {
    if (account.data.address && !allowance.data && !allowance.error && !allowance.loading)
      fetchAllowance({ args: [account.data.address, addresses[appNetwork.id][spender]] })
  }, [
    account.data.address,
    allowance.data,
    allowance.error,
    allowance.loading,
    fetchAllowance,
    spender,
  ])

  return [allowance]
}

const useApproval = (addressOrName) =>
  useContractWrite({ addressOrName, contractInterface: erc20Abi }, 'approve', {
    args: [addresses[appNetwork.id].pCNV, 1],
    overrides: { gasLimit: 210000 },
  })

export function ClaimCard({ signer, afterSuccessfulClaim, merkletree, contractAddress }) {
  const [amount, setAmount] = useState('0')
  const [inputToken, setInputToken] = useState<TokenName>(inputTokens[0])

  const [isLoading, setIsLoading] = useState(false)

  const [claimableAmount, setClaimableAmount] = useState(0)

  // const syncUserClaimableAmount = useCallback(() => {
  //   if (signer) getUserClaimablePCNVAmount(signer).then(setClaimableAmount).catch(console.log)
  // }, [signer])

  // useEffect(() => syncUserClaimableAmount(), [syncUserClaimableAmount])

  const [allowance] = useAllowance(inputToken, 'pCNV')
  const [, approveToken] = useApproval(addresses[appNetwork.id][inputToken])

  // useEffect(() => {
  //   if (allowance.data) console.log(allowance.data)
  // }, [allowance.data])

  const onClaim = async () => {
    setIsLoading(true)
    await claim(signer, amount, inputToken)
      .then(() => {
        // syncUserClaimableAmount()
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
