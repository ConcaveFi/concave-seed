import { ethers, Signer } from 'ethers'
// import { signDaiPermit } from 'eth-permit'
import { merkleTree, getClaimableAmount, leafOf } from './merkletree'
import { getRopstenSdk } from '@dethcrypto/eth-sdk-client'
import { Dai, Frax, PCNV } from '.dethcrypto/eth-sdk-client/esm/types'

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
  if(fraxAllowance < amount ) {
    const fraxApprove = await frax.approve(pCNV.address, maxAmount, { from: userAddress })
    await fraxApprove.wait(1);
  }
  return pCNV.mint(userAddress, frax.address, roundId, maxAmount, amount, proof)
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
  const daiAllowance = await dai.allowance(userAddress, pCNV.address, { from: userAddress })
  if(daiAllowance < amount ) {
  const daiApprove = await dai.approve(pCNV.address, maxAmount, { from: userAddress })
  await daiApprove.wait(1);
  }
  console.log(
    userAddress, dai.address, roundId, maxAmount, amount, proof
  )
  return pCNV.mint(userAddress, dai.address, roundId, maxAmount, amount, proof)

  // const permit = await signDaiPermit(dai.provider, dai.address, userAddress, pCNV.address)
  // return pCNV.claim(
  //   userAddress,
  //   dai.address,
  //   roundId,
  //   maxAmount,
  //   amount,
  //   proof,
  //   permit.expiry,
  //   permit.v,
  //   permit.r,
  //   permit.s,
  // )
}

export const claim = async (
  signer: Signer,
  amount: string,
  inputToken: typeof inputTokens[number],
): Promise<void> => {
  const address = await signer.getAddress()
  const formattedToAddress = ethers.utils.getAddress(address)
  const maxAmount = ethers.utils.parseUnits(getClaimableAmount(address).toString(), 18)
  const proof = merkleTree.getHexProof(leafOf(address))
  const merkleRoot: string = merkleTree.getHexRoot();
  console.log('root')
  console.log(merkleRoot)
  const { pCNV, frax, dai } = getRopstenSdk(signer)
  const tokenIn = { frax, dai }[inputToken]
  const roundId = 0
  console.log({
    tokenIn,
    pCNV,
    formattedToAddress,
    roundId,
    maxAmount,
    amount,
    proof,
  })
  const claimFunc = inputToken === 'dai' ? claimWithDai : claimWithFrax
  const claimTx = await claimFunc(


    tokenIn as any,
    pCNV,
    formattedToAddress,
    roundId,
    maxAmount,
    ethers.utils.parseUnits(amount.toString(), 18),
    proof,
  )
  await claimTx.wait(1) // ?

  // } catch (e) {
  //   console.error(`Error when claiming tokens: ${e}`)
  // }
}