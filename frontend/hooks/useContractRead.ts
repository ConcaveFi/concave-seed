import { useContractRead as _useContractRead } from 'wagmi'

export const useContractRead = (...args) => {
  const [result, read] = _useContractRead(...args)
}
