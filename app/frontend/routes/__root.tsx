// import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

import { createRootRoute, HeadContent, Outlet } from '@tanstack/react-router';
import { TanStackRouterDevtools } from '@tanstack/react-router-devtools';
import { Heading } from '@/catalyst/heading';
import Layout from '@/components/Layout';

export const Route = createRootRoute({
  component: RootComponent,
  notFoundComponent: () => {
    return <Heading color="red">404 - Page Not Found</Heading>;
  },
});

function RootComponent() {
  return (
    <>
      <HeadContent />

      <Layout>
        <Outlet />

        <TanStackRouterDevtools />
      </Layout>
    </>
  );
}
