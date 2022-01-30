import { Container, Flex, Link, Text, Image } from '@chakra-ui/react'
import { Card } from 'components/Card'
import colors from 'theme/colors'
import * as Sentry from '@sentry/nextjs'
import NextErrorComponent, { ErrorProps as NextErrorProps } from 'next/error'
import { NextPageContext } from 'next'

export type ErrorPageProps = {
  err: Error
  statusCode: number
  isReadyToRender: boolean
  children?: React.ReactElement
}

export type ErrorProps = {
  isReadyToRender: boolean
} & NextErrorProps

const ErrorPage = ({ statusCode, isReadyToRender, err }: ErrorPageProps): JSX.Element => {
  if (process.env.NEXT_PUBLIC_APP_STAGE !== 'development') {
    console.warn('Unexpected error caught, it was captured and sent to the cave. Details:')
    console.error(err)
  }
  if (!isReadyToRender && err) {
    // getInitialProps is not called in case of https://github.com/vercel/next.js/issues/8592.
    // As a workaround, we pass err via _app.js so it can be captured
    Sentry.captureException(err)
    // Flushing is not required in this case as it only happens on the clientSentry.captureException(err)
  }
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
                  <Link color="text.highlight" href="https://discord.gg/HG4eUFvZa6">
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

ErrorPage.getInitialProps = async ({ res, err, asPath }: NextPageContext): Promise<ErrorProps> => {
  const errorInitialProps: ErrorProps = (await NextErrorComponent.getInitialProps({
    res,
    err,
  } as NextPageContext)) as ErrorProps

  // Workaround for https://github.com/vercel/next.js/issues/8592, mark when getInitialProps has run
  errorInitialProps.isReadyToRender = true

  // Returning early because we don't want to log 404 errors to Sentry.
  if (res?.statusCode === 404) {
    return { statusCode: 404, isReadyToRender: true }
  }

  if (err) {
    Sentry.captureException(err)
    // Flushing before returning is necessary if deploying to Vercel, see
    // https://vercel.com/docs/platform/limits#streaming-responses
    await Sentry.flush(2000)
    return errorInitialProps
  }

  // If this point is reached, getInitialProps was called without any
  // information about what the error might be. This is unexpected and may
  // indicate a bug introduced in Next.js, so record it in Sentry
  Sentry.captureException(new Error(`_error.js getInitialProps missing data at path: ${asPath}`))
  await Sentry.flush(2000)

  return errorInitialProps
}

export default ErrorPage
