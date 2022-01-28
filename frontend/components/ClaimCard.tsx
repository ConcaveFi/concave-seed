import React, { useEffect, useMemo, useState } from 'react'
import { Button, ButtonProps, Heading, Link, Stack, Text } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import { AmountInput } from './Input'
import { useContractRead, useContractWrite } from 'wagmi'
import { appNetwork } from 'pages/_app'
import { addresses, TokenName } from '../eth-sdk/addresses'
import erc20Abi from 'eth-sdk/abis/erc20.json'
import { useAllowance } from 'hooks/useAllowance'
import { BigNumberish } from 'ethers'
import { getMaxStableBuyAmount, isWhitelisted, leafOf, MerkleTrees } from 'lib/merkletree'
import { parseUnits, formatUnits } from 'ethers/lib/utils'
import CNVAbi from 'eth-sdk/abis/mainnet/pCNV.json'
import { AlreadyClaimedCard } from './AlreadyClaimedCard'
import { ArrowRightIcon } from '@chakra-ui/icons'

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

const useConfirmations = (tx, confirmations, fn = () => null) => {
  const [confirmation, setConfirmation] = useState<'idle' | 'loading' | 'confirmed'>('idle')

  useEffect(() => {
    if (!tx) return
    setConfirmation('loading')
    tx.wait(confirmations)
      .then(() => setConfirmation('confirmed'))
      .then(() => fn())
      .catch(console.log)
  }, [confirmations, fn, tx])

  return confirmation
}

export function ClaimTokenCard({
  userAddress,
  claimingToken,
}: {
  userAddress: string
  claimingToken: TokenName
}) {
  const [amount, setAmount] = useState('0')
  const [inputToken, setInputToken] = useState(inputTokens[0])

  const [allowance, syncAllowance] = useAllowance(inputToken, claimingToken, userAddress)
  const [approveTx, approveToken] = useApproval(
    inputToken,
    claimingToken,
    getMaxStableBuyAmount(userAddress, claimingToken),
  )
  const approveConfirmation = useConfirmations(approveTx.data, 1, () => syncAllowance())

  const [claimableAmount, syncClaimableAmount] = useClaimableAmount(claimingToken, userAddress)

  const formattedAllowance = allowance.data && parseFloat(formatUnits(allowance.data, 18))
  const needsApproval: boolean = formattedAllowance < claimableAmount

  const [claimTx, claim] = useContractWrite(
    { addressOrName: addresses[appNetwork.id][claimingToken], contractInterface: CNVAbi },
    'mint',
  )
  const claimConfirmation = useConfirmations(claimTx.data, 1, () => syncClaimableAmount())

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

  useEffect(() => {
    syncAllowance()
  }, [inputToken])

  const isLoading =
    getState(allowance) === 'loading' ||
    getState(claimTx) === 'loading' ||
    getState(approveTx) === 'loading' ||
    claimConfirmation === 'loading' ||
    approveConfirmation === 'loading'

  if (claimableAmount === 0) return <AlreadyClaimedCard tokenName={claimingToken} />

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
        {needsApproval ? (
          <ApproveButton
            onClick={() => approveToken()}
            isLoading={approveTx.loading}
            tokenToApprove={inputToken}
            loadingText={approveConfirmation === 'loading' && 'Waiting block confirmation'}
          />
        ) : (
          <Button
            onClick={onClaim}
            isLoading={isLoading}
            isDisabled={Number(amount) < 1}
            variant="primary"
            size="large"
            fontSize={24}
            isFullWidth
            loadingText={claimConfirmation === 'loading' && 'Waiting block confirmation'}
          >
            Claim {claimingToken}
          </Button>
        )}
        {/* {approveTx.error && <Text color="red.300">{inputToken.toUpperCase()} not approved</Text>} */}
      </Card>
      <Text fontSize="sm" color="text.3" maxW={400} textAlign="center">
        Feel free to ping us in{' '}
        <Link color="text.highlight" href="https://discord.gg/tB3tPby3">
          discord
        </Link>
      </Text>
    </Stack>
  )
}
