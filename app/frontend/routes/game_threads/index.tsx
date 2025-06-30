import { createFileRoute } from '@tanstack/react-router';

import { fetchGameThreads } from '@/api/gameThreads';
import GameThreadsTable from '@/components/GameThreadsTable';
import Main from '@/components/Main';
import PageHeader from '@/components/PageHeader';

export const Route = createFileRoute('/game_threads/')({
  component: RouteComponent,
  loader: fetchGameThreads,
});

function RouteComponent() {
  const { data: gameThreads } = Route.useLoaderData();

  return (
    <>
      <title>Game Threads ({gameThreads.length})</title>

      <PageHeader>Game Threads</PageHeader>

      <Main>
        <GameThreadsTable gameThreads={gameThreads} />
      </Main>
    </>
  );
}
