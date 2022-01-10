import { Box, Heading, Text, Flex, Container, Button } from '@chakra-ui/react'
import { ClaimCard } from 'components/ClaimCard'
import React from 'react'
import { Layout } from '../components/Layout'

function CNVSeed() {
  return (
    <Layout>
      <Container maxW="container.md">
        <Flex direction="column" gap={12}>
          <Box mt={12}>
            <Heading as="h1">Sacrificial Spoon Offering Receptacle</Heading>
            <Text maxW={520}>Speak softly but carry a big spoon</Text>
          </Box>
          <Flex gap={6} flexWrap="wrap" justify="center">
            <ClaimCard />
          </Flex>
        </Flex>
      </Container>
    </Layout>
  )
}

export default CNVSeed
