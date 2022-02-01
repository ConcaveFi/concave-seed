import React from 'react'
import colors from 'theme/colors'
import { Card } from 'components/Card'
import {Link, Text } from '@chakra-ui/react'

export const NotWhitelistedCard = () => {
  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
      <Text fontSize="xx-large" color="white" textAlign="center">Welcome to Concave Equal Opportunity Fair Launch!</Text>     
      <Text textAlign="center">Wave 1: Feb 2, 2022 at 3PM UTC / 10AM EST </Text>
      <Text textAlign="center">Wave 2: Feb 3, 2022 at 3PM UTC / 10AM EST </Text>
      <Text textAlign="center">Wave 3: Feb 4, 2022 at 3PM UTC / 10AM EST </Text>
      <Text textAlign="center">Wave 4: Feb 5, 2022 at 3PM UTC / 10AM EST </Text>
      <Text color="text.3" textAlign="center"> Find out more information about Concave and the whitelist {' '}
        <Link color="text.highlight" href="https://concave.lol/blog/concave-whitelist?utm_source=seed_app&utm_medium=Website&utm_campaign=concave-whitelist&utm_content=no_whitelist_redirect">
          here
        </Link>
      </Text>
      <Text textAlign="center" color="text.3" fontSize="sm" >If you are here for bbtCNV feel free to ignore this message and open a ticket using #seed-help on discord.</Text>
    </Card>
  )
}