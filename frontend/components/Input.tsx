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
    isNumericString
    variant="unstyled"
    placeholder="0.0"
    fontFamily="heading"
    fontWeight={700}
    fontSize={24}
    _placeholder={{ color: 'text.3' }}
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
        minW="max"
      >
        <Text minW="unset">{selected.toUpperCase()}</Text>
      </MenuButton>
      <MenuList bg="green.500" borderRadius="2xl" minW="min" px={1}>
        {bringToBeginning(tokens, selected).map((name) => (
          <SelectItem key={name} name={name} onClick={() => onSelect(name)} />
        ))}
      </MenuList>
    </Menu>
  )
}

const MaxAllowed = ({
  max,
  currentValue,
  ...props
}: { max: number; currentValue: number } & ButtonProps) => (
  <Button
    borderRadius="full"
    py={1}
    px={3}
    bgColor="whiteAlpha.50"
    gap={1}
    fontSize={12}
    transform={`scale(${currentValue > max ? 1.1 : 1})`}
    fontWeight={currentValue > max ? 700 : 500}
    textColor={currentValue > max ? 'text.1' : 'text.3'}
    height="auto"
    whiteSpace="nowrap"
    {...props}
  >
    Max claimable: {max}
    <Text textColor={'text.highlight'}>Max</Text>
  </Button>
)

const MaxBalance = ({ tokenName, balance, currentValue, ...props }) => (
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
    transform={`scale(${currentValue > balance ? 1.1 : 1})`}
    fontWeight={currentValue > balance ? 700 : 500}
    textColor={currentValue > balance ? 'text.1' : 'text.3'}
    height="auto"
    whiteSpace="nowrap"
    w="min"
    {...props}
  >
    {tokenName.toUpperCase()} balance: {Number(balance).toFixed(2)}
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
    <Flex direction="column" gap={1} px={5} zIndex={2}>
      <InputContainer shadow="down">
        <Stack>
          <Flex justify="space-between">
            <BaseInput
              value={value}
              onValueChange={({ value }) => {
                onChangeValue(value)
              }}
            />
            <Select tokens={tokenOptions} onSelect={onSelectToken} selected={selectedToken} />
          </Flex>
          <Flex flexDirection="row-reverse" justify="space-between">
            <MaxAllowed
              currentValue={Number(value)}
              max={maxAmount}
              onClick={() => onChangeValue(maxAmount.toString())}
            />
            {inputTokenBalance && (
              <MaxBalance
                ml={-3}
                tokenName={selectedToken}
                balance={inputTokenBalance}
                currentValue={Number(value)}
                onClick={() =>
                  onChangeValue(
                    maxAmount < Number(inputTokenBalance)
                      ? maxAmount.toString()
                      : inputTokenBalance.toString(),
                  )
                }
              />
            )}
          </Flex>
        </Stack>
      </InputContainer>
    </Flex>
  )
}
