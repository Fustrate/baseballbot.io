import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { createRootRoute, Link, Outlet } from '@tanstack/react-router';
import { TanStackRouterDevtools } from '@tanstack/react-router-devtools';

const queryClient = new QueryClient();

export const Route = createRootRoute({
  component: RootComponent,
});

function RootComponent() {
  return (
    <QueryClientProvider client={queryClient}>
      <div className="flex gap-2 p-2">
        <Link to="/" className="[&.active]:font-bold">
          Home
        </Link>{' '}
        <Link to="/about" className="[&.active]:font-bold">
          About
        </Link>{' '}
        <Link to="/subreddits" className="[&.active]:font-bold">
          Subreddits
        </Link>
      </div>

      <hr />

      <Outlet />

      <TanStackRouterDevtools />
    </QueryClientProvider>
  );
}
