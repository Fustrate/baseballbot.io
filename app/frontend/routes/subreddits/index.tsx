import { createFileRoute, Link } from '@tanstack/react-router';
import { createColumnHelper, flexRender, getCoreRowModel, useReactTable } from '@tanstack/react-table';
import { postAtFormat } from '@/utilities';

interface SubredditGameThreadOptions {
  enabled: boolean;
  flairId?: string;
  postAt: string;
  sticky?: boolean;
  stickyComment?: string;
  title:
    | string
    | {
        default: string;
        postseason?: string;
      };
}

interface SubredditPregameOptions {
  enabled: boolean;
  postAt: string;
  sticky?: boolean;
  stickyComment?: string;
}

interface SubredditPostgameOptions {
  enabled: boolean;
  sticky?: boolean;
  stickyComment?: string;
  title:
    | string
    | {
        default: string;
        won?: string;
        lost?: string;
      };
}

interface SubredditOffDayOptions {
  enabled: boolean;
  sticky?: boolean;
  stickyComment?: string;
  title: string;
  postAt: string;
  lastRunAt: string;
}

interface SubredditSidebarOptions {
  enabled: boolean;
}

interface SubredditOptions {
  timezone: `America/${'Chicago' | 'Denver' | 'Detroit' | 'Los_Angeles' | 'New_York' | 'Phoenix'}`;
  subreddits?: {
    downcase: boolean;
  };
  stickySlot?: 1 | 2;
  sidebar?: SubredditSidebarOptions;
  gameThreads?: SubredditGameThreadOptions;
  pregame?: SubredditPregameOptions;
  postgame?: SubredditPostgameOptions;
  offDay?: SubredditOffDayOptions;
}

interface Subreddit {
  id: number;
  name: string;
  abbreviation: string;
  options: SubredditOptions;
  account: {
    id: number;
    name: string;
  };
}

async function fetchSubreddits(): Promise<Subreddit[]> {
  return fetch('//baseballbot.io.test/subreddits.json')
    .then((res) => res.json())
    .then((data) => data.data);
}

export const Route = createFileRoute('/subreddits/')({
  component: RouteComponent,
  loader: fetchSubreddits,
});

const linkClasses = 'text-sky-600 hover:text-sky-900';

const columnHelper = createColumnHelper<Subreddit>();

const columns = [
  columnHelper.display({
    id: 'name',
    header: () => 'Name',
    cell: (info) => (
      <Link to="/subreddits/$subredditId" params={{ subredditId: info.row.original.name }} className={linkClasses}>
        {info.row.original.name}
      </Link>
    ),
  }),
  columnHelper.accessor((row) => row.abbreviation, {
    id: 'abbreviation',
    header: () => 'Team',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor((row) => row.account.name, {
    id: 'accountName',
    header: () => 'Account',
    cell: (info) => info.getValue(),
  }),
  columnHelper.display({
    id: 'sidebar',
    header: () => 'Sidebar',
    cell: (info) => info.row.original.options.sidebar?.enabled && <i className="fa fa-check" />,
  }),
  columnHelper.accessor((row) => row.options.gameThreads, {
    id: 'gameThreads',
    header: () => 'Game Threads',
    cell: (info) => info.getValue()?.enabled && postAtFormat(info.getValue()?.postAt),
  }),
  columnHelper.accessor((row) => row.options.pregame, {
    id: 'pregame',
    header: () => 'Pre Game',
    cell: (info) => info.getValue()?.enabled && postAtFormat(info.getValue()?.postAt),
  }),
  columnHelper.accessor((row) => row.options.postgame?.enabled, {
    id: 'postgame',
    header: () => 'Post Game',
    cell: (info) => info.getValue() && <i className="fa fa-check" />,
  }),
  columnHelper.accessor((row) => row.options.offDay, {
    id: 'offDay',
    header: () => 'Off Day',
    cell: (info) => info.getValue()?.enabled && postAtFormat(info.getValue()?.postAt),
  }),
];

function RouteComponent() {
  const subreddits = Route.useLoaderData();

  const table = useReactTable({
    data: subreddits,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  return (
    <>
      <header className="bg-white shadow-xs">
        <div className="mx-auto max-w-7xl px-4 py-4 sm:px-6 lg:px-8">
          <h1 className="font-semibold text-lg/6 text-slate-900">Subreddits</h1>
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
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </>
  );
}
