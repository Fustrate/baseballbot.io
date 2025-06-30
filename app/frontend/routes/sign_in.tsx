import { createFileRoute } from '@tanstack/react-router';
import Main from '@/components/Main';
import PageHeader from '@/components/PageHeader';

export const Route = createFileRoute('/sign_in')({
  component: RouteComponent,
});

function RouteComponent() {
  return (
    <>
      <PageHeader>Game Threads</PageHeader>

      <Main>
        <div className="overflow-hidden bg-white text-slate-900 ring-1 ring-slate-300 sm:mx-0 sm:rounded-lg dark:bg-slate-950 dark:text-slate-300 dark:ring-slate-800">
          <p className="px-4 py-2">I should probably get this reimplemented.</p>
        </div>
      </Main>
    </>
  );
}
