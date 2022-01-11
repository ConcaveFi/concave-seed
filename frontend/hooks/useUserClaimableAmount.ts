import { getUserClaimablePCNVAmount } from 'lib/claim'
import { useEffect, useState } from 'react'
import { useSigner } from './useSigner'

// bad hook made fast
export const useUserClaimableAmount = () => {
  const [{ data: signer, loading: signerLoading }] = useSigner()
  const [claimableAmount, setClaimableAmount] = useState(null)
  const [isLoading, setIsLoading] = useState(true)
  useEffect(() => {
    getUserClaimablePCNVAmount(signer)
      .then(setClaimableAmount)
      .catch(console.log)
      .finally(() => setIsLoading(false))
  }, [signer])

  return [{ data: claimableAmount, loading: isLoading }]
}
