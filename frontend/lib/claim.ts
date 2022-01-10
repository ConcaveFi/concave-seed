import { merkleTree, getClaimableAmount, leafOf } from './merkletree'
import { ethers, providers } from 'ethers'
import { chain } from 'wagmi'

const pCNVAddress = process.env.CONTRACT_ADDRESS
const ethProvider = new providers.InfuraProvider(chain.mainnet.id, process.env.INFURA_ID)
const pCNVContract = new ethers.Contract(pCNVAddress, [], ethProvider)

export const claimAirdrop = async (address: string): Promise<void> => {
  if (!address) throw new Error('Not Authenticated')

  const formattedAddress = ethers.utils.getAddress(address)
  const indexOfTokens = getClaimableAmount(address)
  const proof: string[] = merkleTree.getHexProof(leafOf(address))
  try {
    const tx = await pCNVContract.claim(formattedAddress, indexOfTokens, proof)
    await tx.wait(1)
    // await syncStatus()
  } catch (e) {
    console.error(`Error when claiming tokens: ${e}`)
  }
}