import React from 'react'
import colors from 'theme/colors'
import { Card } from 'components/Card'
import {Link, Text } from '@chakra-ui/react'

export const NotWhitelistedCard = () => {
  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
      <Text>The aCNV sale for Wave 1 will begin Feb 2, 2022 at 3PM UTC / 10AM EST </Text>
      <Text>Wave 2: Feb 3, 2022 at 3PM UTC / 10AM EST </Text>
      <Text>Wave 3: Feb 4, 2022 at 3PM UTC / 10AM EST </Text>
      <Text>Wave 4: Feb 5, 2022 at 3PM UTC / 10AM EST </Text>
      <Text fontSize="sm" color="text.3" maxW={400} textAlign="center">
        Find out more information about Concave and the whitelist {' '}
        <Link color="text.highlight" href="https://concave.lol/blog/concave-whitelist/">
          here
        </Link>
      </Text>
    </Card>
  )
}
