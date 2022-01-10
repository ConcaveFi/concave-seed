import { ChevronDownIcon } from '@chakra-ui/icons'
import {
  Button,
  Flex,
  Input,
  Menu,
  MenuButton,
  MenuItem,
  MenuItemProps,
  MenuList,
  Stack,
  Text,
  useStyles,
} from '@chakra-ui/react'
import Image from 'next/image'
import React, { useEffect, useState } from 'react'
import colors from 'theme/colors'
import { fonts } from 'theme/foundations'
import { gradientStroke } from 'theme/utils/gradientStroke'

const BaseInput = (props) => (
  <Input
    variant="unstyled"
    placeholder="0.0"
    fontFamily="heading"
    fontWeight={700}
    fontSize={24}
    type="number"
    _placeholder={{ color: 'text.1' }}
    {...props}
  />
)

const InputContainer = (props) => (
  <Flex
    mx={-5}
    px={5}
    py={3}
    w={400}
    h={90}
    borderRadius="2xl"
    bgGradient={colors.gradients.green}
    align={'start'}
    {...props}
  />
)

const selectItemStyles = {
  borderRadius: 'full',
  py: 1,
  px: 3,
  height: 'auto',
  fontWeight: 600,
}

const SelectItem = ({ name, ...props }: { name: string } & MenuItemProps) => (
  <MenuItem sx={selectItemStyles} {...props}>
    <TokenIcon tokenName={name} />
    <Text ml={2}>{name.toUpperCase()}</Text>
  </MenuItem>
)

const TokenIcon = ({ tokenName }: { tokenName: string }) => (
  <Image src={`/assets/tokens/${tokenName}.svg`} width="18px" height="18px" alt="" />
)

const bringToBeginning = (arr, elem) => arr.sort((x, y) => (x == elem ? -1 : y == elem ? 1 : 0))

const Select = ({
  tokens,
  selected,
  onSelect,
}: {
  tokens: string[]
  selected: typeof tokens[number]
  onSelect: (tokenName: string) => void
}) => {
  return (
    <Menu placement="bottom-end" autoSelect>
      <MenuButton
        as={Button}
        bgColor="whiteAlpha.50"
        sx={selectItemStyles}
        leftIcon={<TokenIcon tokenName={selected} />}
        rightIcon={<ChevronDownIcon />}
      >
        {selected.toUpperCase()}
      </MenuButton>
      <MenuList bg="green.500" borderRadius="2xl" minW="min" px={1}>
        {bringToBeginning(tokens, selected).map((name) => (
          <SelectItem name={name} onClick={() => onSelect(name)} />
        ))}
      </MenuList>
    </Menu>
  )
}

const MaxAllowed = ({ max, onClick }) => (
  <Flex
    align="center"
    borderRadius="full"
    py={1}
    px={3}
    bgColor="whiteAlpha.50"
    gap={1}
    fontSize={12}
    textColor="grey.700"
    whiteSpace="nowrap"
    onClick={onClick}
  >
    Max Whitelisted: {max}
    <Text textColor={'text.highlight'}>Max</Text>
  </Flex>
)

const inputTokenOptions = ['dai', 'frax']
export function AmountInput() {
  const [inputToken, setInputToken] = useState(inputTokenOptions[0])
  return (
    <Flex direction="column" gap={1} px={5}>
      {/* <Text textColor="text.3" fontWeight={700}>
        Get with
      </Text> */}
      <InputContainer shadow="down">
        <BaseInput />
        <Stack align="end">
          <Select tokens={inputTokenOptions} onSelect={setInputToken} selected={inputToken} />
          <MaxAllowed max="500,000" onClick={() => null} />
        </Stack>
      </InputContainer>
    </Flex>
  )
}
