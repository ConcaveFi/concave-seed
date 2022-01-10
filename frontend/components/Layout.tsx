import { Container } from '@chakra-ui/react'
import React from 'react'
import { Head, MetaProps } from './Meta'
import { TopBar } from './TopBar'

interface LayoutProps {
  children: React.ReactNode
  customMeta?: MetaProps
}

export const Layout = ({ children, customMeta }: LayoutProps): JSX.Element => {
  return (
    <>
      <Head customMeta={customMeta} />
      <TopBar />
      <main>
        <Container maxWidth="container.xl">{children}</Container>
      </main>
    </>
  )
}
