import { ChevronDownIcon } from '@chakra-ui/icons'
import {
  Button,
  ButtonProps,
  chakra,
  Flex,
  Input,
  InputProps,
  Menu,
  MenuButton,
  MenuItem,
  MenuItemProps,
  MenuList,
  Stack,
  Text,
} from '@chakra-ui/react'
import Image from 'next/image'
import React from 'react'
import colors from 'theme/colors'
import NumberFormat, { NumberFormatProps } from 'react-number-format'
import { TokenName } from 'eth-sdk/addresses'

const BaseInput = (props: InputProps & NumberFormatProps) => (
  <Input
    as={NumberFormat}
    thousandSeparator
    variant="unstyled"
    placeholder="0.0"
    fontFamily="heading"
    fontWeight={700}
    fontSize={24}
    _placeholder={{ color: 'text.1' }}
    {...props}
  />
)

const InputContainer = (props) => (
  <Flex
    mx={-5}
    px={5}
    py={3}
    maxW={400}
    h={90}
    borderRadius="2xl"
    bgGradient={colors.gradients.green}
    align={'start'}
    {...props}
  />
)

const selectItemStyles = {
  borderRadius: 'full',
  py: 2,
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
          <SelectItem key={name} name={name} onClick={() => onSelect(name)} />
        ))}
      </MenuList>
    </Menu>
  )
}

const MaxAllowed = ({ max, ...props }: { max: number } & ButtonProps) => (
  <Button
    borderRadius="full"
    py={1}
    px={3}
    bgColor="whiteAlpha.50"
    gap={1}
    fontSize={12}
    fontWeight={500}
    height="auto"
    textColor="text.3"
    whiteSpace="nowrap"
    {...props}
  >
    Max claimable: {max}
    <Text textColor={'text.highlight'}>Max</Text>
  </Button>
)

const MaxBalance = ({ tokenName, balance, ...props }) => (
  <Button
    borderRadius="full"
    py={1}
    px={3}
    bg="none"
    _hover={{
      bg: 'whiteAlpha.50',
    }}
    gap={1}
    fontSize={12}
    fontWeight={500}
    height="auto"
    textColor="text.3"
    whiteSpace="nowrap"
    w="min"
    {...props}
  >
    {tokenName.toUpperCase()} balance: {balance}
    {/* <Text textColor={'text.highlight'}>Max</Text> */}
  </Button>
)

export function AmountInput({
  maxAmount,
  value,
  onChangeValue,
  tokenOptions,
  selectedToken,
  onSelectToken,
  inputTokenBalance,
}: {
  inputTokenBalance: string
  maxAmount: number
  value: string
  onChangeValue: (value: string) => void
  tokenOptions: TokenName[]
  selectedToken: typeof tokenOptions[number]
  onSelectToken: (token: typeof selectedToken) => void
}) {
  return (
    <Flex direction="column" gap={1} px={5}>
      <InputContainer shadow="down">
        <Flex direction="column" justify="space-between" h="100%">
          <BaseInput
            value={value}
            onValueChange={({ value }) => onChangeValue(value)}
            isAllowed={({ floatValue }) => floatValue <= maxAmount}
          />
          {inputTokenBalance && (
            <MaxBalance
              ml={-3}
              tokenName={selectedToken}
              balance={inputTokenBalance}
              onClick={() => onChangeValue(inputTokenBalance.toString())}
            />
          )}
        </Flex>
        <Stack align="end">
          <Select tokens={tokenOptions} onSelect={onSelectToken} selected={selectedToken} />
          <MaxAllowed max={maxAmount} onClick={() => onChangeValue(maxAmount.toString())} />
        </Stack>
      </InputContainer>
    </Flex>
  )
}
