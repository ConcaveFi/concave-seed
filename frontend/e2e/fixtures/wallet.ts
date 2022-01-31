import { test as base } from '@playwright/test'
import { ethers, Wallet } from 'ethers'
import { parseEther, hexlify } from 'ethers/lib/utils'

const sendEthTransaction = async (sender: Wallet, to: string, amount) => {
  const provider = new ethers.providers.InfuraProvider('ropsten')
  const signer = sender.connect(provider)
  const gasPrice = await provider.getGasPrice()
  const from = signer.address
  amount = amount === 'all' ? await signer.getBalance() : amount
  return signer.sendTransaction({
    from,
    to,
    value: parseEther(amount),
    nonce: provider.getTransactionCount(from, 'latest'),
    gasLimit: hexlify(210000),
    gasPrice,
  })
}

// Creates an wallet with some ropstein funds in the fixture
// returns the funds to the faucet after done
// TODO: maybe try using a different faster testnet to speedup tests
base.extend<{ wallet: ethers.Wallet }>({
  wallet: async ({ page }, use) => {
    const faucet = ethers.Wallet.fromMnemonic(process.env.FAUCET_MNMONIC)
    const wallet = ethers.Wallet.createRandom()
    await sendEthTransaction(faucet, wallet.address, 0.1)
    await use(wallet)
    await sendEthTransaction(wallet, faucet.address, 'all')
  },
})

export { expect } from '@playwright/test'
