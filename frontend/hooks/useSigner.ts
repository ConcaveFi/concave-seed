import * as React from 'react'
import { Signer } from 'ethers'

import { useAccount, useContext } from 'wagmi'

type State = {
  data?: Signer
  error?: Error
  loading?: boolean
}

const initialState: State = {
  data: undefined,
  error: undefined,
  loading: false,
}

export const useSigner = () => {
  const [{ data: account }] = useAccount()
  const [state, setState] = React.useState<State>(initialState)
  const wagmi = useContext()

  const getSigner = React.useCallback(async () => {
    try {
      setState((x) => ({ ...x, error: undefined, loading: true }))
      const signer = await account?.connector?.getSigner()
      setState((x) => ({ ...x, data: signer, loading: false }))

      return signer
    } catch (error_) {
      const error = <Error>error_
      setState((x) => ({ ...x, data: undefined, error, loading: false }))
    }
  }, [account?.connector])

  React.useEffect(() => {
    getSigner()
  }, [wagmi.state.cacheBuster, getSigner])

  return [state, getSigner] as const
}
