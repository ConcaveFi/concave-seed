import { ethers, Signer } from 'ethers'
import { signERC2612Permit, signDaiPermit } from 'eth-permit'
import { merkleTree, getClaimableAmount, leafOf } from './merkletree'
import { getRopstenSdk, RopstenSdk } from '@dethcrypto/eth-sdk-client'
import { Provider } from '@ethersproject/abstract-provider'
import { Dai } from '.dethcrypto/eth-sdk-client/esm/types'

export const inputTokens = ['dai', 'frax']

export const claim = async (
  address: string,
  provider: Provider,
  signer: Signer,
  amount: string,
  inputToken: typeof inputTokens[number],
): Promise<void> => {
  if (!address) throw new Error('Not Authenticated')

  const formattedToAddress = ethers.utils.getAddress(address)
  const maxAmount = ethers.utils.parseUnits(getClaimableAmount(address).toString(), 18)
  const proof = merkleTree.getHexProof(leafOf(address))

  const { pCNV, frax, dai } = getRopstenSdk(signer)
  const tokenIn = { frax, dai }[inputToken]
  const roundId = 1
  if (inputToken === 'dai') {
    const permit = await signDaiPermit(provider, dai.address, formattedToAddress, pCNV.address)
    const daiPermit = await dai.permit(
      formattedToAddress,
      permit.spender,
      permit.nonce,
      permit.expiry,
      true,
      permit.v,
      permit.r,
      permit.s,
      { from: formattedToAddress },
    )
    daiPermit.wait(1) // do we need to wait for confirmations on this ?
    await pCNV.claimWithPermit(
      formattedToAddress,
      tokenIn.address,
      roundId,
      maxAmount,
      amount,
      proof,
      permit.expiry,
      permit.v,
      permit.r,
      permit.s,
    )
  } else {
    await frax.approve(formattedToAddress, maxAmount, { from: formattedToAddress })
  }

  try {
    const tx = await pCNV.claimWithPermit(
      formattedToAddress,
      tokenIn.address,
      roundId,
      maxAmount,
      amount,
      proof,
      permit.deadline,
      permit.v,
      permit.r,
      permit.s,
    )
    await tx.wait(1)
    // await syncStatus()
  } catch (e) {
    console.error(`Error when claiming tokens: ${e}`)
  }
}
