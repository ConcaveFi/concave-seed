import { BigNumber, ethers, Signer } from 'ethers'
import { signDaiPermit } from 'eth-permit'
import { merkleTree, leafOf, getClaimablePCNVAmount } from './merkletree'
import { getRopstenSdk, getMainnetSdk } from '@dethcrypto/eth-sdk-client'
import { Dai, Frax, PCNV } from '.dethcrypto/eth-sdk-client/esm/types'
import { chain } from 'wagmi'

const ethSdk = process.env.NODE_ENV === 'production' ? getMainnetSdk : getRopstenSdk

export const inputTokens = ['dai', 'frax']

const claimWithFrax = async (
  frax: Frax,
  pCNV: PCNV,
  userAddress,
  roundId,
  maxAmount,
  amount,
  proof,
) => {
  const fraxAllowance = await frax.allowance(userAddress, pCNV.address, { from: userAddress })
  if (fraxAllowance.lt(amount)) {
    const fraxApprove = await frax.approve(pCNV.address, maxAmount, { from: userAddress })
    await fraxApprove.wait(1)
  }
  return pCNV.mint(userAddress, frax.address, roundId, maxAmount, amount, proof, {
    gasLimit: 210000,
  })
}

const claimWithDai = async (
  dai: Dai,
  pCNV: PCNV,
  userAddress,
  roundId,
  maxAmount,
  amount,
  proof,
) => {
  // const daiAllowance = await dai.allowance(userAddress, pCNV.address, { from: userAddress })
  // if (daiAllowance < amount) {
  //   const daiApprove = await dai.approve(pCNV.address, maxAmount, { from: userAddress })
  //   await daiApprove.wait(1)
  // }
  // console.log(userAddress, dai.address, roundId, maxAmount, amount, proof)
  // return pCNV.mint(userAddress, dai.address, roundId, maxAmount, amount, proof)

  const daiAllowance = await dai.allowance(userAddress, pCNV.address, { from: userAddress })
  if (daiAllowance.lt(amount)) {
    const SECOND = 1000
    const expiry = Math.trunc((Date.now() + 120 * SECOND) / SECOND)
    const nonce = await dai.nonces(userAddress)

    const permit = await signDaiPermit(
      dai.signer,
      {
        name: 'Dai Stablecoin',
        version: '1',
        chainId: chain.ropsten.id,
        verifyingContract: dai.address,
      },
      userAddress,
      pCNV.address,
      expiry,
      nonce as any,
    )

    const permitDaiTx = await dai.permit(
      permit.holder,
      permit.spender,
      permit.nonce,
      permit.expiry,
      true,
      permit.v,
      permit.r,
      permit.s,
      { gasLimit: 210000 },
    )
    await permitDaiTx.wait(1)
  }

  return pCNV.mint(userAddress, dai.address, roundId, maxAmount, amount, proof, {
    gasLimit: 210000,
  })
}

export const pCNVSeedPrice = 3
const roundId = 0

export const getUserClaimablePCNVAmount = async (signer) => {
  const userAddress = await signer.getAddress()
  const { pCNV } = ethSdk(signer)
  const userAlreadyClaimedAmount = ethers.utils.parseUnits(
    (await pCNV.claimedAmounts(roundId, userAddress)).toString(),
    18,
  )
  const userStillClaimableAmount = BigNumber.from(getClaimablePCNVAmount(userAddress)).sub(
    userAlreadyClaimedAmount,
  )
  return userStillClaimableAmount
}

export const claim = async (
  signer: Signer,
  amount: string,
  inputToken: typeof inputTokens[number],
): Promise<void> => {
  const address = await signer.getAddress()
  const userAddress = ethers.utils.getAddress(address)

  const { pCNV, frax, dai } = ethSdk(signer)

  const tokenIn = { frax, dai }[inputToken]
  const tokenInDecimals = await tokenIn.decimals()

  const userClaimablePCNVAmount = await getUserClaimablePCNVAmount(signer)
  const maxStableClaimableAmount = userClaimablePCNVAmount.mul(pCNVSeedPrice).toString()
  const proof = merkleTree.getHexProof(leafOf(address))

  const claimFunc = inputToken === 'dai' ? claimWithDai : claimWithFrax
  const claimTx = await claimFunc(
    tokenIn as any,
    pCNV,
    userAddress,
    roundId,
    ethers.utils.parseUnits(maxStableClaimableAmount.toString(), tokenInDecimals),
    ethers.utils.parseUnits(amount.toString(), tokenInDecimals),
    proof,
  )
  await claimTx.wait(1) // ?

  // } catch (e) {
  //   console.error(`Error when claiming tokens: ${e}`)
  // }
}