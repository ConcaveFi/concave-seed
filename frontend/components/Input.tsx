import { ChevronDownIcon } from '@chakra-ui/icons'
import { Button, Flex, Input, Stack, Text } from '@chakra-ui/react'
import Image from 'next/image'
import React from 'react'
import colors from 'theme/colors'
import { fonts } from 'theme/foundations'

const BaseInput = (props) => (
  <Input
    variant="unstyled"
    placeholder="0.0"
    fontFamily={fonts.heading}
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
    w={400}
    h={90}
    borderRadius="2xl"
    bgGradient={colors.gradients.green}
    align={'start'}
    {...props}
  />
)

const Select = () => (
  <Flex align="center" borderRadius="full" py={1} px={3} bgColor="whiteAlpha.50" gap={1}>
    <Image src="/assets/tokens/dai.svg" width="18px" height="18px" alt="" />
    <Text fontWeight={'600'}>DAI</Text>
    <ChevronDownIcon />
  </Flex>
)

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

export function FromInput() {
  return (
    <Flex direction="column" gap={1} px={5}>
      {/* <Text textColor="text.3" fontWeight={700}>
        Get with
      </Text> */}
      <InputContainer shadow="down">
        <BaseInput />
        <Stack align="end">
          <Select />
          <MaxAllowed max="500,000" onClick={() => null} />
        </Stack>
      </InputContainer>
    </Flex>
  )
}

export function ToInput() {
  return (
    <Flex direction="column" gap={1} px={5}>
      <Text textColor={'grey.500'} fontWeight={700}>
        To (estimated)
      </Text>
      <InputContainer shadow="up">
        <BaseInput />
        <Stack align="end" fontWeight={600}>
          <Text fontSize={24}>gCNV</Text>
          <Text fontSize={14} color="grey.700">
            ~$2,914
          </Text>
        </Stack>
      </InputContainer>
    </Flex>
  )
}
