import { addresses, TokenName } from 'eth-sdk/addresses'
import { appNetwork } from 'pages/_app'
import { useMemo } from 'react'
import { erc20ABI, useContractRead } from 'wagmi'

export const useAllowance = (allowed: TokenName, spender: TokenName, userAddress: string) => {
  return useContractRead(
    { addressOrName: addresses[appNetwork.id][allowed], contractInterface: erc20ABI },
    'allowance',
    useMemo(
      () => ({
        skip: !userAddress,
        // watch: true,
        args: [userAddress, addresses[appNetwork.id][spender]],
        overrides: { from: userAddress },
      }),
      [spender, userAddress],
    ),
  )
}
