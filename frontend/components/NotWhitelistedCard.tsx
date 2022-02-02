import React from 'react'
import colors from 'theme/colors'
import { Card } from 'components/Card'
import {Heading, Link, Text } from '@chakra-ui/react'

export const NotWhitelistedCard = () => {
  return (
    <Card shadow="up" bgGradient={colors.gradients.green} px={10} py={8} gap={4}>
     <Heading fontSize="xx-large" color="" textAlign="center">This wallet is not whitelisted for Wave 1!</Heading>    
      <Text textAlign="center">Wave 2: Feb 3, 2022 at 3PM UTC / 10AM EST </Text>
      <Text textAlign="center">Wave 3: Feb 4, 2022 at 3PM UTC / 10AM EST </Text>
      <Text textAlign="center">Wave 4: Feb 5, 2022 at 3PM UTC / 10AM EST </Text>
      <Text textAlign="center">The whitelist sale will be launched on ETH mainnet in waves, we want to reward our most loyal supporters and also make it an enjoyable experience without a typical rush of people crashing a website!</Text> 
      <Text textAlign="center">Please ensure you know which wave category you are in and that you connect with your whitelisted address.</Text>
      <Text textAlign="center">*In order to participate in this token sale, please ensure that you have enough FRAX or DAI in your wallet to make your purchase. Please also ensure that you have some $ETH to cover the gas fees when interacting with the contract.</Text>
      <Text color="text.3" textAlign="center"> Find out more information about Concave and the whitelist {' '}
        <Link color="text.highlight" href="https://concave.lol/blog/concave-whitelist?utm_source=seed_app&utm_medium=Website&utm_campaign=concave-whitelist&utm_content=no_whitelist_redirect">
          here
        </Link>
      </Text>
      <Text textAlign="center" color="text.3" fontSize="sm" >If you are here for bbtCNV feel free to ignore this message and open a ticket using #seed-help on discord.</Text>
    </Card>
  )
}