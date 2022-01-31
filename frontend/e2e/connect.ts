import { test, expect } from '@playwright/test'
import dappetter from '@sriharikapu/dappetter'
import { ethers } from 'ethers'

test('test metamask', async ({ playwright, wallet }) => {
  const browser = await dappetter.launch({ launch: playwright.chromium.launch })
  const metamask = await dappetter.getMetamask(browser)

  await metamask.importPK(wallet.privateKey)

  await metamask.switchNetwork('ropsten')
})
