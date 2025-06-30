import { toHumanDate } from '@fustrate/rails/utilities';
import { createFileRoute, Link } from '@tanstack/react-router';
import { createColumnHelper, getCoreRowModel, useReactTable } from '@tanstack/react-table';
import { DateTime } from 'luxon';

import { fetchGameThreads, type GameThread } from '@/api/gameThreads';

import Badge from '@/components/Badge';
import DataTable from '@/components/DataTable';
import Main from '@/components/Main';
import PageHeader from '@/components/PageHeader';

function StatusBadge({ gameThread }: { gameThread: GameThread }) {
  const { postAt, startsAt, status } = gameThread;

  if (postAt < DateTime.now() && status === 'Future') {
    return (
      <Badge color="red" className="w-full">
        Error
      </Badge>
    );
  }

  if (startsAt < DateTime.now() && status === 'Posted') {
    return (
      <Badge color="green" className="w-full">
        Live
      </Badge>
    );
  }

  return <Badge className="w-full">{status}</Badge>;
}

export const Route = createFileRoute('/game_threads/')({
  component: RouteComponent,
  loader: fetchGameThreads,
  head: () => ({
    meta: [{ title: 'Game Threads' }],
  }),
});

const linkClasses = 'text-sky-600 hover:text-sky-900';

const columnHelper = createColumnHelper<GameThread>();

const columns = [
  columnHelper.display({
    id: 'pk',
    header: () => 'PK',
    cell: (info) => (
      <a href={`//www.mlb.com/gameday/${info.row.original.gamePk}`} className={linkClasses}>
        {info.row.original.gamePk}
      </a>
    ),
  }),
  columnHelper.display({
    id: 'title',
    header: () => 'Title',
    cell: (info) =>
      info.row.original.postId ? (
        <a href={`//redd.it/${info.row.original.postId}`} className={linkClasses}>
          {info.row.original.title}
        </a>
      ) : (
        info.row.original.title
      ),
  }),
  columnHelper.display({
    id: 'subreddit',
    header: () => 'Subreddit',
    cell: (info) => (
      <Link
        to="/subreddits/$subredditId"
        params={{ subredditId: info.row.original.subreddit.name }}
        className={linkClasses}
      >
        {info.row.original.subreddit.name}
      </Link>
    ),
  }),
  columnHelper.accessor((row) => row.startsAt, {
    id: 'startsAt',
    header: () => 'Starts At',
    cell: (info) => <span className="whitespace-nowrap">{toHumanDate(info.getValue(), true)}</span>,
    // meta: { cellClasses: 'hidden xl:table-cell' } as ColumnMeta,
  }),
  columnHelper.accessor((row) => row.postAt, {
    id: 'postAt',
    header: () => 'Post At',
    cell: (info) => {
      if (info.row.original.postAt.hasSame(info.row.original.startsAt, 'day')) {
        return <span className="whitespace-nowrap">{info.getValue().toFormat('t')}</span>;
      }

      return <span className="whitespace-nowrap">{toHumanDate(info.getValue(), true)}</span>;
    },
    // meta: { cellClasses: 'hidden lg:table-cell' } as ColumnMeta,
  }),
  columnHelper.accessor((row) => row.status, {
    id: 'status',
    header: () => 'Status',
    cell: (info) => <StatusBadge gameThread={info.row.original} />,
  }),
];

function RouteComponent() {
  const { data: gameThreads } = Route.useLoaderData();

  const table = useReactTable({
    data: gameThreads,
    columns,
    getCoreRowModel: getCoreRowModel(),
    manualSorting: true,
  });

  return (
    <>
      <PageHeader>Game Threads</PageHeader>

      <Main>
        <DataTable table={table} />
      </Main>
    </>
  );
}
