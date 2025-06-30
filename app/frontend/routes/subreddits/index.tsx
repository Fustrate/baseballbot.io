import { createFileRoute, Link } from '@tanstack/react-router';
import { createColumnHelper, getCoreRowModel, useReactTable } from '@tanstack/react-table';

import { fetchSubreddits, type Subreddit } from '@/api/subreddits';

import DataTable from '@/components/DataTable';
import Main from '@/components/Main';
import PageHeader from '@/components/PageHeader';

import { postAtFormat } from '@/utilities';

export const Route = createFileRoute('/subreddits/')({
  component: RouteComponent,
  loader: fetchSubreddits,
  head: () => ({
    meta: [{ title: 'Subreddits' }],
  }),
});

const linkClasses = 'text-sky-600 hover:text-sky-900 dark:text-sky-300 dark:hover:text-sky-100';

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
      <PageHeader>Subreddits</PageHeader>

      <Main>
        <DataTable table={table} />
      </Main>
    </>
  );
}
