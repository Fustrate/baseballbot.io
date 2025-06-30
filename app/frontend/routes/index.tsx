import { createFileRoute } from '@tanstack/react-router';

import { fetchGameThreads } from '@/api/gameThreads';
import GameThreadsTable from '@/components/GameThreadsTable';
import Main from '@/components/Main';
import PageHeader from '@/components/PageHeader';

export const Route = createFileRoute('/')({
  component: RouteComponent,
  loader: fetchGameThreads,
  head: () => ({
    meta: [{ title: "Today's Game Threads" }],
  }),
});

function RouteComponent() {
  const { data: gameThreads } = Route.useLoaderData();

  return (
    <>
      <title>Today's Game Threads</title>

      <PageHeader>Today's Game Threads</PageHeader>

      <Main>
        <GameThreadsTable gameThreads={gameThreads} />
      </Main>
    </>
  );
}
