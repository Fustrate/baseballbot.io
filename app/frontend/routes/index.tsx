import { createFileRoute } from '@tanstack/react-router';

import { fetchGameThreads, type GameThread } from '@/api/gameThreads';
import GameThreadsTable from '@/components/GameThreadsTable';
import Main from '@/components/Main';
import PageHeader from '@/components/PageHeader';
import type { GameThreadStatus } from '@/utilities/constants';

export const Route = createFileRoute('/')({
  component: RouteComponent,
  loader: fetchGameThreads,
  head: () => ({
    meta: [{ title: "Today's Game Threads" }],
  }),
});

const gameThreadStatusOrder: GameThreadStatus[] = [
  'Posted',
  'Pregame',
  'Future',
  'Over',
  'External',
  'Removed',
  'Postponed',
];

function gameThreadSortOrder(gameThread: GameThread): string {
  return [
    gameThreadStatusOrder.indexOf(gameThread.status),
    gameThread.startsAt.toISO(),
    gameThread.gamePk,
    gameThread.subreddit.name,
  ].join('/');
}

function RouteComponent() {
  const { data: gameThreads } = Route.useLoaderData();

  const sortedGameThreads = gameThreads.sort((a, b) => {
    return gameThreadSortOrder(a) < gameThreadSortOrder(b) ? -1 : 1;
  });

  return (
    <>
      <title>Today's Game Threads</title>

      <PageHeader>Today's Game Threads</PageHeader>

      <Main>
        <GameThreadsTable gameThreads={sortedGameThreads} />
      </Main>
    </>
  );
}
