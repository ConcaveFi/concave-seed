import { Container, Flex, Link, Text, Image } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'

function Error({ statusCode }) {
  return (
    <>
      <Container maxWidth="container.xl">
        <Flex justify="space-between" align="center" py={3}>
          <Image
            src={'/images/CNV_white_svg.svg'}
            alt="concave logo"
            maxWidth="100px"
            maxHeight="120px"
            position="relative"
          />
        </Flex>
      </Container>
      <main>
        <Container maxW="container.md">
          <Flex direction="column" gap={12}>
            <Flex gap={6} flexWrap="wrap" justify="center">
              <Card
                shadow="up"
                bgGradient={colors.gradients.green}
                px={10}
                py={8}
                gap={4}
                align="center"
              >
                <Text>Something went wrong</Text>
                <Text>
                  please ping us on{' '}
                  <Link color="text.highlight" href="https://discord.gg/tB3tPby3">
                    discord
                  </Link>
                </Text>
              </Card>
            </Flex>
          </Flex>
        </Container>
      </main>
    </>
  )
}

Error.getInitialProps = ({ res, err }) => {
  const statusCode = res ? res.statusCode : err ? err.statusCode : 404
  return { statusCode }
}

export default Error
