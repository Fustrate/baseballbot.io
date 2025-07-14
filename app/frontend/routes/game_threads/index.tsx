import { createFileRoute } from '@tanstack/react-router';
import { DateTime } from 'luxon';
import { z } from 'zod';
import type { GameThread } from '@/api/gameThreads';
import { fetchGameThreads } from '@/api/gameThreads';
import { Button } from '@/catalyst/button';
import { Heading } from '@/catalyst/heading';
import GameThreadsTable from '@/components/GameThreadsTable';
import type { GameThreadStatus } from '@/utilities/constants';

const gameThreadsSearchSchema = z.object({
  date: z.iso.date().default(() => DateTime.now().toISODate()),
});

export const Route = createFileRoute('/game_threads/')({
  validateSearch: gameThreadsSearchSchema,
  loaderDeps: ({ search: { date } }) => ({ date }),
  component: RouteComponent,
  loader: ({ deps: { date } }) => fetchGameThreads({ date: DateTime.fromISO(date) }),
  staleTime: 1000 * 60 * 5, // 5 minutes
  head: () => ({
    meta: [{ title: 'Game Threads' }],
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
  const { date: searchDate } = Route.useSearch();

  const date = DateTime.fromISO(searchDate);

  const sortedGameThreads = gameThreads.sort((a, b) => {
    return gameThreadSortOrder(a) < gameThreadSortOrder(b) ? -1 : 1;
  });

  const previousDate = date.minus({ days: 1 });
  const nextDate = date.plus({ days: 1 });

  return (
    <>
      <div className="flex w-full flex-wrap items-end justify-between gap-4 border-zinc-950/10 border-b pb-6 dark:border-white/10">
        <Heading>{date.toLocaleString(DateTime.DATE_FULL)}</Heading>
        <div className="flex gap-4">
          <Button
            outline
            href={`/game_threads?date=${previousDate.toISODate()}`}
            className="inline-flex items-center gap-1"
          >
            <i className="fas fa-angle-left" />
            <span className="hidden md:inline">{previousDate.toFormat('M/d')}</span>
          </Button>
          <Button
            outline
            href={`/game_threads?date=${nextDate.toISODate()}`}
            className="inline-flex items-center gap-1"
          >
            <span className="hidden md:inline">{nextDate.toFormat('M/d')}</span>
            <i className="fas fa-angle-right" />
          </Button>
        </div>
      </div>

      <GameThreadsTable gameThreads={sortedGameThreads} />
    </>
  );
}
