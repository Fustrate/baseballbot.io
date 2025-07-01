import { createFileRoute } from '@tanstack/react-router';
import { AuthLayout } from '@/catalyst/auth-layout';
import { Heading } from '@/catalyst/heading';

export const Route = createFileRoute('/sign_in')({
  component: RouteComponent,
});

function RouteComponent() {
  return (
    <>
      <div className="flex w-full flex-wrap items-end justify-between gap-4 border-zinc-950/10 border-b pb-6 dark:border-white/10">
        <Heading>Sign In</Heading>
      </div>

      <AuthLayout>
        <p className="px-4 py-2">I should probably get this reimplemented.</p>
      </AuthLayout>
    </>
  );
}
