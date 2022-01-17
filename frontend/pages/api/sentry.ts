import { withSentry, captureException } from '@sentry/nextjs'

const sentryHost = 'o1117457.ingest.sentry.io'

/*
  Sentry is blocked by ad blockers 
  so we tunnel sentry requests thru our domain to not get blocked
*/
async function handler(req, res) {
  try {
    const envelope = req.body
    const pieces = envelope.split('\n')
    const header = JSON.parse(pieces[0])

    const { host, pathname } = new URL(header.dsn)
    if (host !== sentryHost) throw new Error(`invalid host: ${host}`)

    const projectId = pathname.endsWith('/') ? pathname.slice(0, -1) : pathname

    return fetch(`https://${sentryHost}/api/${projectId}/envelope/`, {
      method: 'POST',
      body: envelope,
    }).then((r) => r.json())
  } catch (e) {
    captureException(e)
    return res.status(400).json({ status: 'invalid request' })
  }
}

export default withSentry(handler)
