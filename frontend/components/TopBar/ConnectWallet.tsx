import React, { useState } from 'react'
import { Button, Image, Menu, MenuButton, MenuItem, MenuList } from '@chakra-ui/react'
import { useAccount, useConnect } from 'wagmi'
import colors from 'theme/colors'

const miniAddress = (address) =>
  `${address.substr(0, 6)}...${address.substr(address.length - 6, address.length)}`

const DisconnectButton = () => {
  const [{ data, loading }, disconnect] = useAccount({ fetchEns: true })
  return (
    <Menu placement="bottom-end">
      <MenuButton as={Button} isLoading={loading} borderRadius="xl">
        {data.ens || miniAddress(data.address)}
      </MenuButton>
      <MenuList bg="green.500" borderRadius="xl" px={1}>
        <MenuItem borderRadius="lg" onClick={disconnect}>
          Disconnect
        </MenuItem>
      </MenuList>
    </Menu>
  )
}

const ConnectButton = ({ onError }: { onError: (e: Error) => void }) => {
  const [{ data, error }, connect] = useConnect()
  return (
    <>
      <Menu placement="bottom-end">
        <MenuButton
          as={Button}
          variant="primary.outline"
          bgGradient={colors.gradients.green}
          size="large"
          borderWidth={2}
        >
          Connect wallet
        </MenuButton>
        <MenuList bg="green.500" borderRadius="xl" minW="min" px={1}>
          {data.connectors.map((connector) => (
            <MenuItem
              borderRadius="xl"
              icon={<Image maxWidth="20px" src={`/connectors/${connector.name}.png`} alt="" />}
              key={connector.id}
              onClick={() => connect(connector)}
            >
              {connector.name}
            </MenuItem>
          ))}
        </MenuList>
        {/* <UnsuportedNetworkModal
          isOpen={state === 'unsupportedNetwork'}
          onClose={() => setState('idle')}
        /> */}
      </Menu>
    </>
  )
}

export function ConnectWallet(): JSX.Element {
  const [{ data }] = useConnect()

  return data.connected ? <DisconnectButton /> : <ConnectButton onError={(e) => console.log(e)} />
}
