const { withSentryConfig } = require('@sentry/nextjs')

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
}

/** @type {import('@sentry/cli').SentryCliOptions} */
const sentryConfig = {
  silent: true, // Suppresses all logss
}

// Make sure adding Sentry config is the last code to run before exporting, to
// ensure that your source maps include changes from all other Webpack plugins
module.exports = withSentryConfig(nextConfig, sentryConfig)
