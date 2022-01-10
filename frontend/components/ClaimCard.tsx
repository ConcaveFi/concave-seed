import React from 'react'
import Image from 'next/image'
import { Text, Button, HStack, Stack } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import { FromInput } from './Input'

export function ClaimCard({}) {
  return (
    <Card shadow="up" bgGradient={colors.gradients.green}>
      <Card px={10} py={8} gap={4}>
        <FromInput />
        <Button variant="primary" size="large" fontSize={24} isFullWidth>
          Claim pCNV
        </Button>
      </Card>
    </Card>
  )
}
