import { ethers, Signer } from 'ethers'
import { signERC2612Permit, signDaiPermit } from 'eth-permit'
import { merkleTree, getClaimableAmount, leafOf } from './merkletree'
import { getRopstenSdk } from '@dethcrypto/eth-sdk-client'
import { Provider } from '@ethersproject/abstract-provider'
import contractsConfig from 'eth-sdk.config'

const daiAddresses = Object.values(contractsConfig.contracts)
  .map((network) => network?.dai as string)
  .filter(Boolean)

export const inputTokens = ['dai', 'frax']

const signPermit = (
  provider: Provider,
  token: string,
  owner: string,
  spender: string,
  deadline?: number,
  value?: string,
  nonce?: number,
) => {
  if (daiAddresses.includes(token))
    return signDaiPermit(provider, token, owner, spender, deadline, nonce).then((a) => ({
      ...a,
      deadline: a.expiry,
    }))
  return signERC2612Permit(provider, token, owner, spender, value, deadline, nonce)
}

export const claim = async (
  address: string,
  provider: Provider,
  signer: Signer,
  amount: string,
  inputToken: typeof inputTokens[number],
): Promise<void> => {
  if (!address) throw new Error('Not Authenticated')

  const formattedToAddress = ethers.utils.getAddress(address)
  const maxAmount = getClaimableAmount(address)
  const proof: string[] = merkleTree.getHexProof(leafOf(address))

  const { pCNV, frax, dai } = getRopstenSdk(signer)
  const tokenIn = { frax, dai }[inputToken]
  const roundId = 1

  const permit = await signPermit(provider, tokenIn.address, address, pCNV.address)

  const a = await dai.permit(
    formattedToAddress,
    permit.spender,
    permit.nonce,
    permit.deadline,
    true,
    permit.v,
    permit.r,
    permit.s,
  )

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
