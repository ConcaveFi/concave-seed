import React, { useEffect, useMemo, useState } from 'react'
import { Button, ButtonProps, Heading, Link, Stack, Text } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import { AmountInput } from './Input'
import { useBalance, useContractRead, useContractWrite, useWaitForTransaction } from 'wagmi'
import { appNetwork } from 'components/wagmi/WagmiProvider'
import { addresses, TokenName } from '../eth-sdk/addresses'
import erc20Abi from 'eth-sdk/abis/erc20.json'
import { useAllowance } from 'hooks/useAllowance'
import { BigNumberish } from 'ethers'
import { getMaxStableBuyAmount, isWhitelisted, leafOf, MerkleTrees } from 'lib/merkletree'
import { parseUnits, formatUnits } from 'ethers/lib/utils'
import CNVAbi from 'eth-sdk/abis/mainnet/pCNV.json'
import { AlreadyClaimedCard } from './AlreadyClaimedCard'
import { ArrowRightIcon } from '@chakra-ui/icons'
import { gaEvent } from '../lib/analytics'

const getState = ({ data, error, loading }) => {
  if (!data && !error && !loading) return 'idle'
  if (loading) return 'loading'
  if (data) return 'succeded'
  if (error) return 'errored'
  return 'idle'
}

const useApproval = (
  tokenToBeApproved: TokenName,
  spender: TokenName,
  amountToApprove: BigNumberish,
) =>
  useContractWrite(
    { addressOrName: addresses[appNetwork.id][tokenToBeApproved], contractInterface: erc20Abi },
    'approve',
    {
      args: [
        addresses[appNetwork.id][spender],
        parseUnits(amountToApprove.toString(), 18 /* 18 ???? better way */),
      ],
      overrides: { gasLimit: 210000 },
    },
  )

const ApproveButton = ({ tokenToApprove, ...props }) => {
  return (
    <Button {...props} variant="primary" size="large" fontSize={24} isFullWidth>
      {`Approve ${tokenToApprove.toUpperCase()}`}
    </Button>
  )
}

const useClaimableAmount = (tokenName: TokenName, userAddress) => {
  const [alreadyClaimedAmount, syncClaimableAmount] = useContractRead(
    { addressOrName: addresses[appNetwork.id][tokenName], contractInterface: CNVAbi },
    'spentAmounts',
    useMemo(
      () => ({
        args: [MerkleTrees[tokenName].getHexRoot(), userAddress],
        overrides: { from: userAddress },
      }),
      [tokenName, userAddress],
    ),
  )
  return [
    getMaxStableBuyAmount(userAddress, tokenName) -
      parseFloat(formatUnits(alreadyClaimedAmount.data || 0, 18)),
    syncClaimableAmount,
  ] as const
}

const inputTokens = ['dai', 'frax'] as TokenName[]

export function ClaimCard({ userAddress }: { userAddress: string }) {
  const [claiming, setClaiming] = useState<TokenName>(
    isWhitelisted(userAddress, 'bbtCNV') ? 'bbtCNV' : 'aCNV',
  )
  return (
    <Stack>
      <Stack mb={4}>
        <Heading>Claiming {claiming}</Heading>
        {claiming === 'bbtCNV' && isWhitelisted(userAddress, 'aCNV') && (
          <YourAlsoWhitelisted tokenName="aCNV" onClick={() => setClaiming('aCNV')} />
        )}
        {claiming === 'aCNV' && isWhitelisted(userAddress, 'bbtCNV') && (
          <YourAlsoWhitelisted tokenName="bbtCNV" onClick={() => setClaiming('bbtCNV')} />
        )}
      </Stack>
      <ClaimTokenCard userAddress={userAddress} claimingToken={claiming} />
    </Stack>
  )
}

const YourAlsoWhitelisted = ({ tokenName, ...props }: { tokenName: TokenName } & ButtonProps) => (
  <Button
    borderRadius="2xl"
    w="min"
    p={0}
    _focus={{
      outline: 'none',
      opacity: 0.6,
    }}
    _active={{
      bg: 'none',
    }}
    _hover={{
      bg: 'none',
      color: 'text.3',
    }}
    bg="none"
    {...props}
  >
    {`You're also whitelisted for claiming ${tokenName}`}
    <ArrowRightIcon ml={3} h={3} />
  </Button>
)

export function ClaimTokenCard({
  userAddress,
  claimingToken,
}: {
  userAddress: string
  claimingToken: TokenName
}) {
  const [amount, setAmount] = useState<string>()
  const [inputToken, setInputToken] = useState(inputTokens[0])

  const [{ data: inputTokenBalance }, syncInputTokenBalance] = useBalance({
    addressOrName: userAddress,
    token: addresses[appNetwork.id][inputToken],
    formatUnits: 18,
  })

  const [allowance, syncAllowance] = useAllowance(inputToken, claimingToken, userAddress)
  const [approveTx, approveToken] = useApproval(
    inputToken,
    claimingToken,
    getMaxStableBuyAmount(userAddress, claimingToken),
  )
  const [approveConfirmation] = useWaitForTransaction({ wait: approveTx.data?.wait })
  useEffect(() => {
    if (approveConfirmation.data) syncAllowance()
  }, [approveConfirmation.data, syncAllowance])

  const [claimableAmount, syncClaimableAmount] = useClaimableAmount(claimingToken, userAddress)

  const formattedAllowance = allowance.data && parseFloat(formatUnits(allowance.data, 18))
  const needsApproval: boolean = formattedAllowance < claimableAmount

  const [claimTx, claim] = useContractWrite(
    { addressOrName: addresses[appNetwork.id][claimingToken], contractInterface: CNVAbi },
    'mint',
  )
  const [claimConfirmation] = useWaitForTransaction({ wait: claimTx.data?.wait })
  useEffect(() => {
    if (!claimConfirmation.data) return
    // when we split the components right, do some caches (swr/react-query), this useEffects to sync stuff will be clearer
    syncClaimableAmount()
    syncInputTokenBalance()

    gaEvent({action: `claimed ${claimingToken}`, params: {
        'event_category' : 'whitelist',
        'event_label' : claimConfirmation.data.transactionHash,
        'metric1': parseFloat(amount).toFixed(2)
      }} )

    setState('already_claimed')
  }, [claimConfirmation.data, syncClaimableAmount, syncInputTokenBalance])

  const onClaim = () => {
    const tokenIn = addresses[appNetwork.id][inputToken]
    const tokenInDecimals = 18
    const proof = MerkleTrees[claimingToken].getHexProof(leafOf(claimingToken)(userAddress))
    const maxClaimableAmount = getMaxStableBuyAmount(userAddress, claimingToken)

    claim({
      args: [
        userAddress,
        tokenIn,
        parseUnits(maxClaimableAmount.toString(), tokenInDecimals),
        parseUnits(amount, tokenInDecimals),
        proof,
      ],
      overrides: {
        gasLimit: 210000,
      },
    })
  }

  const [state, setState] = useState(claimableAmount === 0 ? 'already_claimed' : 'claiming')
  useEffect(() => {
    setState(claimableAmount !== 0 && !claimConfirmation.data ? 'claiming' : 'already_claimed')
  }, [claimConfirmation.data, claimableAmount])

  useEffect(() => {
    syncAllowance()
  }, [inputToken, syncAllowance])

  const isLoading = [
    getState(allowance),
    getState(claimTx),
    getState(approveTx),
    getState(approveConfirmation),
    getState(claimConfirmation),
  ].includes('loading')

  const isClaimDisabled =
    Number(amount || 0) < 1 ||
    Number(amount) > Number(inputTokenBalance?.formatted) ||
    Number(amount) > claimableAmount

  if (state === 'already_claimed')
    return (
      <>
        <AlreadyClaimedCard
          tokenName={claimingToken}
          amountClaimed={getMaxStableBuyAmount(userAddress, claimingToken) - claimableAmount}
        />
        {claimableAmount > 0 && (
          <Button
            variant="secondary"
            bgGradient={colors.gradients.green}
            borderRadius="xl"
            onClick={() => setState('claiming')}
          >
            Claim more
          </Button>
        )}
      </>
    )

  return (
    <Stack spacing={3} align="center">
      <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
        <AmountInput
          inputTokenBalance={inputTokenBalance?.formatted}
          maxAmount={claimableAmount}
          value={amount}
          onChangeValue={setAmount}
          tokenOptions={inputTokens}
          selectedToken={inputToken}
          onSelectToken={setInputToken}
        />
        {needsApproval ? (
          <ApproveButton
            onClick={() => approveToken()}
            isLoading={approveTx.loading}
            tokenToApprove={inputToken}
            loadingText={approveConfirmation.loading && 'Waiting block confirmation'}
          />
        ) : (
          <Button
            onClick={onClaim}
            isLoading={isLoading}
            isDisabled={isClaimDisabled}
            variant="primary"
            size="large"
            fontSize={24}
            isFullWidth
            loadingText={claimConfirmation.loading && 'Waiting block confirmation'}
          >
            Claim {claimingToken}
          </Button>
        )}
        {/* {approveTx.error && <Text color="red.300">{inputToken.toUpperCase()} not approved</Text>} */}
      </Card>
      <Text fontSize="sm" color="text.3" maxW={400} textAlign="center">
        Feel free to ping us in{' '}
        <Link color="text.highlight" href="https://discord.gg/HG4eUFvZa6">
          discord
        </Link>
      </Text>
    </Stack>
  )
}
