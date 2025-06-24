import type { PaginatedData } from '@fustrate/rails/generic-table';
import { toHumanDate } from '@fustrate/rails/utilities';
import { createFileRoute, Link } from '@tanstack/react-router';
import { createColumnHelper, flexRender, getCoreRowModel, useReactTable } from '@tanstack/react-table';
import { DateTime } from 'luxon';
import Badge from '@/badge';

interface GameThread {
  id: number;
  postAt: string;
  startsAt: string;
  status: string;
  title: string;
  postId: string | null;
  gamePk: number;
  preGamePostId: string | null;
  postGamePostId: string | null;
  createdAt: string;
  updatedAt: string;
  subreddit: {
    id: number;
    name: string;
    teamId: number | null;
  };
}

function StatusBadge({ gameThread }: { gameThread: GameThread }) {
  const postAt = DateTime.fromISO(gameThread.postAt);
  const startsAt = DateTime.fromISO(gameThread.startsAt);

  if (postAt < DateTime.now() && gameThread.status === 'Future') {
    return (
      <Badge color="red" className="w-full">
        Error
      </Badge>
    );
  }

  if (startsAt < DateTime.now() && gameThread.status === 'Posted') {
    return (
      <Badge color="green" className="w-full">
        Live
      </Badge>
    );
  }

  return <Badge className="w-full">{gameThread.status}</Badge>;
}

async function fetchGameThreads(): Promise<PaginatedData<GameThread>> {
  return fetch('//baseballbot.io.test/game_threads.json').then((res) => res.json());
}

export const Route = createFileRoute('/game_threads/')({
  component: RouteComponent,
  loader: fetchGameThreads,
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
  columnHelper.accessor((row) => DateTime.fromISO(row.postAt), {
    id: 'postAt',
    header: () => 'Post At',
    cell: (info) => <span className="whitespace-nowrap">{toHumanDate(info.getValue(), true)}</span>,
  }),
  columnHelper.accessor((row) => DateTime.fromISO(row.startsAt), {
    id: 'startsAt',
    header: () => 'Starts At',
    cell: (info) => <span className="whitespace-nowrap">{toHumanDate(info.getValue(), true)}</span>,
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
      <header className="bg-white shadow-xs">
        <div className="mx-auto max-w-7xl px-4 py-4 sm:px-6 lg:px-8">
          <h1 className="font-semibold text-lg/6 text-slate-900">Game Threads</h1>
        </div>
      </header>

      <main>
        <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
          <div className="overflow-hidden bg-white ring-1 ring-slate-300 sm:mx-0 sm:rounded-lg">
            <table className="w-full">
              <thead className="border-slate-300 border-b bg-slate-50">
                {table.getHeaderGroups().map((headerGroup) => (
                  <tr key={headerGroup.id}>
                    {headerGroup.headers.map((header) => (
                      <th key={header.id} className="px-3 py-3.5 text-left">
                        {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody className="bg-white">
                {table.getRowModel().rows.map((row) => (
                  <tr key={row.id} className="even:bg-slate-50">
                    {row.getVisibleCells().map((cell) => (
                      <td key={cell.id} className="px-3 py-4">
                        {flexRender(cell.column.columnDef.cell, cell.getContext())}
                      </td>
                    ))}
                  </tr>
                ))}
                {table.getRowModel().rows.length === 0 && (
                  <tr>
                    <td colSpan={columns.length} className="px-3 py-4 text-center text-slate-500">
                      No game threads found.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </>
  );
}
