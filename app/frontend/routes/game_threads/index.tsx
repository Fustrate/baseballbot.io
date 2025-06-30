import { createFileRoute, Link } from '@tanstack/react-router';
import { DateTime } from 'luxon';
import { z } from 'zod/v4';
import type { GameThread } from '@/api/gameThreads';
import { fetchGameThreads } from '@/api/gameThreads';
import GameThreadsTable from '@/components/GameThreadsTable';
import Main from '@/components/Main';
import PageHeader from '@/components/PageHeader';
import type { GameThreadStatus } from '@/utilities/constants';

// Trying to get this working with real Date or DateTime objects is fucking insane. It should not be this hard to parse
// a date string with DateTime, check isValid, and then return the object.
const gameThreadsSearchSchema = z.object({
  date: z
    .string()
    .regex(/^20\d{2}-(?:0[1-9]|1[012])-(?:0[1-9]|[12]\d|3[01])$/)
    .transform((date) => (DateTime.fromISO(date).isValid ? date : DateTime.now().toISODate()))
    .default(() => DateTime.now().toISODate()),
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

  const previousButton = (
    <Link
      to="/game_threads"
      search={{ date: previousDate.toISODate() as string }}
      className="inline-flex items-center gap-1"
    >
      <i className="far fa-angle-left" />
      <span className="hidden md:inline">{previousDate.toFormat('M/d')}</span>
    </Link>
  );

  const nextButton = (
    <Link
      to="/game_threads"
      search={{ date: nextDate.toISODate() as string }}
      className="inline-flex items-center gap-1"
    >
      <span className="hidden md:inline">{nextDate.toFormat('M/d')}</span>
      <i className="far fa-angle-right" />
    </Link>
  );

  return (
    <>
      <PageHeader leftButton={previousButton} rightButton={nextButton}>
        {date.toLocaleString(DateTime.DATE_FULL)}
      </PageHeader>

      <Main>
        <GameThreadsTable gameThreads={sortedGameThreads} />
      </Main>
    </>
  );
}
