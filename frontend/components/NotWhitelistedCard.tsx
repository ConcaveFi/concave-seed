import React from 'react'
import colors from 'theme/colors'
import { Card } from 'components/Card'
import {Heading, Link, Text } from '@chakra-ui/react'

export const NotWhitelistedCard = () => {
  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
     <Heading fontSize="xx-large" color="" textAlign="center">Presale for aCNV has concluded!</Heading>    
      <Text color="text.3" textAlign="center"> Find more information about Concave and the presale {' '}
        <Link color="text.highlight" href="https://concave.lol/blog/concave-whitelist?utm_source=seed_app&utm_medium=Website&utm_campaign=concave-whitelist&utm_content=no_whitelist_redirect">
          here
        </Link>
      </Text>
      <Text textAlign="center" color="text.3" fontSize="sm" >If you are here for bbtCNV feel free to ignore this message and open a ticket using #seed-help on discord.</Text>
    </Card>
  )
}