import React, { useMemo, useState } from 'react'
import { Button, Link, Spinner, Stack, Text } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import { AmountInput } from './Input'
import { useContractRead, useContractWrite } from 'wagmi'
import { appNetwork } from 'pages/_app'
import { addresses, TokenName } from 'eth-sdk/addresses'
import erc20Abi from 'eth-sdk/abis/erc20.json'
import { useAllowance } from 'hooks/useAllowance'
import { BigNumberish } from 'ethers'
import {
  getMaxClaimableAmount,
  getMaxStableBuyAmount,
  getStableClaimableAmount,
  isWhitelisted,
  leafOf,
  MerkleTrees,
} from 'lib/merkletree'
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
  const [alreadyClaimedAmount] = useContractRead(
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
  return (
    getMaxClaimableAmount(userAddress, tokenName) -
    parseFloat(formatUnits(alreadyClaimedAmount.data || 0, 18))
  )
}

const inputTokens = ['dai', 'frax'] as TokenName[]

export function ClaimCard({ userAddress }: { userAddress: string }) {
  if (isWhitelisted(userAddress, 'bbtCNV')) return <ClaimBBTCNVCard userAddress={userAddress} />
  return <ClaimCCNVCard userAddress={userAddress} />
}

const YourAlsoWhitelisted = ({ tokenName }) => (
  <Button borderRadius="2xl" p={6} variant="secondary" bgGradient={colors.gradients.green}>
    Your also whitelisted for claiming {tokenName}
    <ArrowRightIcon ml={3} h={3} />
  </Button>
)

const ClaimCCNVCard = ({ userAddress }) => {
  const claimableAmountCCNV = useClaimableAmount('cCNV', userAddress)

  return (
    <Stack spacing={3} align="center">
      {claimableAmountCCNV === 0 ? (
        <AlreadyClaimedCard tokenName="cCNV" />
      ) : (
        <>
          <ClaimTokenCard
            userAddress={userAddress}
            claimableAmount={claimableAmountCCNV}
            claimingToken="cCNV"
          />
          <Text fontSize="sm" color="text.3" maxW={400} textAlign="center">
            Feel free to ping us in{' '}
            <Link color="text.highlight" href="https://discord.gg/tB3tPby3">
              discord
            </Link>
          </Text>
        </>
      )}
      {isWhitelisted(userAddress, 'bbtCNV') && <YourAlsoWhitelisted tokenName="bbtCNV" />}
    </Stack>
  )
}

const ClaimBBTCNVCard = ({ userAddress }) => {
  const claimableAmountBbtCNV = useClaimableAmount('bbtCNV', userAddress)

  return (
    <Stack spacing={3} align="center">
      {claimableAmountBbtCNV === 0 ? (
        <AlreadyClaimedCard tokenName="cCNV" />
      ) : (
        <>
          <ClaimTokenCard
            userAddress={userAddress}
            claimableAmount={claimableAmountBbtCNV}
            claimingToken="bbtCNV"
          />
          <Text fontSize="sm" color="text.3" maxW={400} textAlign="center">
            Feel free to ping us in{' '}
            <Link color="text.highlight" href="https://discord.gg/tB3tPby3">
              discord
            </Link>{' '}
            if you need help claiming using a multisig
          </Text>
        </>
      )}
      {isWhitelisted(userAddress, 'cCNV') && <YourAlsoWhitelisted tokenName="cCNV" />}
    </Stack>
  )
}

export function ClaimTokenCard({
  userAddress,
  claimingToken,
  claimableAmount,
}: {
  userAddress: string
  claimingToken: TokenName
  claimableAmount: number
}) {
  const [amount, setAmount] = useState('0')
  const [inputToken, setInputToken] = useState(inputTokens[0])

  const [allowance] = useAllowance(inputToken, claimingToken, userAddress)
  const [approveTx, approveToken] = useApproval(
    inputToken,
    claimingToken,
    getMaxStableBuyAmount(userAddress, claimingToken),
  )
  console.log(getMaxStableBuyAmount(userAddress, claimingToken))
  console.log(allowance.data?.lt(getMaxStableBuyAmount(userAddress, claimingToken)))

  const needsApproval: boolean =
    !approveTx.data || allowance.data?.lt(getMaxStableBuyAmount(userAddress, claimingToken))

  const [claimTx, claim] = useContractWrite(
    { addressOrName: addresses[appNetwork.id][claimingToken], contractInterface: CNVAbi },
    'mint',
    useMemo(() => ({ overrides: { gasLimit: 210000 } }), []),
  )

  const isLoading =
    getState(allowance) === 'loading' ||
    getState(claimTx) === 'loading' ||
    getState(approveTx) === 'loading'

  const onClaim = () => {
    const tokenIn = addresses[appNetwork.id][inputToken]
    const tokenInDecimals = 18
    const proof = MerkleTrees[claimingToken].getHexProof(leafOf(claimingToken)(userAddress))
    const maxClaimableAmount = getMaxClaimableAmount(userAddress, claimingToken)

    claim({
      args: [
        userAddress,
        tokenIn,
        parseUnits(maxClaimableAmount.toString(), tokenInDecimals),
        parseUnits(amount, tokenInDecimals),
        proof,
      ],
    })
  }

  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
      <AmountInput
        maxAmount={getStableClaimableAmount(claimableAmount, claimingToken)}
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
        >
          Claim {claimingToken}
        </Button>
      )}
      {/* {approveTx.error && <Text color="red.300">{inputToken.toUpperCase()} not approved</Text>} */}
    </Card>
  )
}
