import { addresses, TokenName } from 'eth-sdk/addresses'
import MerkleTrees, { getMaxClaimableAmount } from 'lib/merkletree'
import { appNetwork } from 'pages/_app'
import useSWR from 'swr'
import { useContractRead } from 'wagmi'
import { formatUnits } from 'ethers/lib/utils'
import CNVAbi from 'eth-sdk/abis/mainnet/pCNV.json'

export const useClaimableAmount = (tokenName: TokenName, userAddress) => {
  const [, read] = useContractRead(
    { addressOrName: addresses[appNetwork.id][tokenName], contractInterface: CNVAbi },
    'spentAmounts',
  )

  const { data: alreadyClaimedAmount } = useSWR(
    userAddress ? `${tokenName}-claimable` : null, // no fetch if no userAddress
    () =>
      read({
        args: [MerkleTrees[tokenName].getHexRoot(), userAddress],
      }),
  )

  return (
    alreadyClaimedAmount.data &&
    getMaxClaimableAmount(userAddress, tokenName) -
      parseFloat(formatUnits(alreadyClaimedAmount.data, 18))
  )
}
