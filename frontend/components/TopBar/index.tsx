import { Container, Flex, Box, Image } from '@chakra-ui/react'
import { ConnectWallet } from './ConnectWallet'

export const TopBar = () => {
  return (
    <Box as="header">
      <Container maxWidth="container.xl">
        <Flex justify="space-between" align="center" maxHeight="72px">
          <Image
            src={'/images/CNV_white_svg.svg'}
            alt="concave logo"
            maxWidth="100px"
            maxHeight="120px"
            position="relative"
          />
          <ConnectWallet />
        </Flex>
      </Container>
    </Box>
  )
}
