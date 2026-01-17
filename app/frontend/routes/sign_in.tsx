import { createFileRoute, Navigate } from '@tanstack/react-router';
import { AuthLayout } from '@/catalyst/auth-layout';
import { ButtonLink } from '@/catalyst/button';
import { Heading } from '@/catalyst/heading';
import { Text } from '@/catalyst/text';
import { useAuth } from '@/hooks/useAuth';

export const Route = createFileRoute('/sign_in')({
  component: RouteComponent,
  head: () => ({
    meta: [{ title: 'Sign In' }],
  }),
});

function RouteComponent() {
  const { isLoggedIn, isLoading } = useAuth();

  // Redirect if already logged in
  if (isLoggedIn && !isLoading) {
    return <Navigate to="/" />;
  }

  return (
    <AuthLayout>
      <div className="w-full max-w-md space-y-6">
        <div className="text-center">
          <Heading level={2}>Sign into Baseballbot.io</Heading>
          <Text className="mt-2">Sign in with your Reddit account to manage game threads and subreddit settings.</Text>
        </div>

        <div className="space-y-4">
          <ButtonLink href="/sessions/new" reloadDocument className="w-full" color="dark">
            <i className="fab fa-reddit-alien" />
            Sign in with Reddit
          </ButtonLink>

          <Text className="text-center text-sm">
            By signing in, you agree to authenticate via Reddit OAuth. We only access the permissions needed to manage
            your subreddit.
          </Text>
        </div>
      </div>
    </AuthLayout>
  );
}
