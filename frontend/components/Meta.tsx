import NextHead from 'next/head'
import { useRouter } from 'next/router'
import React from 'react'

export const HOST_URL = process.env.NEXT_PUBLIC_VERCEL_URL
export const TWITTER = process.env.NEXT_PUBLIC_TWITTER

export interface MetaProps {
  description?: string
  image?: string
  title: string
  type?: string
}

export const Head = ({ customMeta }: { customMeta?: MetaProps }): JSX.Element => {
  const router = useRouter()
  router.basePath
  const meta: MetaProps = {
    title: 'Concave Whitelist',
    description: 'Concave is at heart a builder/community fund CO-OP. Our aim is to be one of the biggest CO-OPs in the defi ecosystem, combining our innovative collective strengths and experiences within our team and community to create innovative USPs for our protocol to accrue value back to every single token holder.',
    image: `${HOST_URL}/images/site-preview.png`,
    type: 'website',
    ...customMeta,
  }

  return (
    <NextHead>
      <title>{meta.title}</title>
      <meta content={meta.description} name="description" />
      <meta property="og:url" content={`${HOST_URL}${router.asPath}`} />
      <link rel="canonical" href={`${HOST_URL}${router.asPath}`} />
      <meta property="og:type" content={meta.type} />
      <meta property="og:site_name" content="Concave" />
      <meta property="og:description" content={meta.description} />
      <meta property="og:title" content={meta.title} />
      <meta property="og:image" content={meta.image} />
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:site" content={TWITTER} />
      <meta name="twitter:title" content={meta.title} />
      <meta name="twitter:description" content={meta.description} />
      <meta name="twitter:image" content={meta.image} />
    </NextHead>
  )
}
