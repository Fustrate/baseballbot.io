import { createFileRoute } from '@tanstack/react-router';
import { Heading } from '@/catalyst/heading';
import Main from '@/components/Main';

export const Route = createFileRoute('/sign_in')({
  component: RouteComponent,
});

function RouteComponent() {
  return (
    <>
      <div className="flex w-full flex-wrap items-end justify-between gap-4 border-zinc-950/10 border-b pb-6 dark:border-white/10">
        <Heading>Sign In</Heading>
      </div>

      <Main>
        <div className="overflow-hidden bg-white text-slate-900 ring-1 ring-slate-300 sm:mx-0 sm:rounded-lg dark:bg-slate-950 dark:text-slate-300 dark:ring-slate-800">
          <p className="px-4 py-2">I should probably get this reimplemented.</p>
        </div>
      </Main>
    </>
  );
}
