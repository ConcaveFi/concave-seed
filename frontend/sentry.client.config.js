import * as Sentry from '@sentry/nextjs'

const SENTRY_DSN = process.env.SENTRY_DSN || process.env.NEXT_PUBLIC_SENTRY_DSN

Sentry.init({
  dsn: SENTRY_DSN || 'https://8ad3b7bdd77248c688b20e76a58d13b2@o1117457.ingest.sentry.io/6151318',
  tunnel: '/api/sentry',
  // Adjust this value in production, or use tracesSampler for greater control
  tracesSampleRate: 1.0,
})
