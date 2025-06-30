import { flexRender, type Table } from '@tanstack/react-table';
import { cn } from '@/utilities';

export interface ColumnMeta {
  cellClasses?: string;
}

export default function DataTable({ table }: { table: Table<any> }) {
  return (
    <div className="overflow-hidden bg-white ring-1 ring-slate-300 sm:mx-0 sm:rounded-lg dark:ring-slate-800">
      <table className="w-full text-slate-900 dark:text-slate-300">
        <DataTableHeader table={table} />

        <DataTableBody table={table} />
      </table>
    </div>
  );
}

function DataTableHeader({ table }: { table: Table<any> }) {
  return (
    <thead className="border-slate-300 border-b bg-slate-50 dark:border-slate-800 dark:bg-sky-900 dark:text-sky-100">
      {table.getHeaderGroups().map((headerGroup) => (
        <tr key={headerGroup.id}>
          {headerGroup.headers.map((header) => (
            <th
              key={header.id}
              className={cn('px-3 py-3.5 text-left', (header.column.columnDef.meta as ColumnMeta)?.cellClasses)}
            >
              {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
            </th>
          ))}
        </tr>
      ))}
    </thead>
  );
}

function DataTableBody({ table }: { table: Table<any> }) {
  return (
    <tbody className="bg-white dark:bg-slate-950">
      {table.getRowModel().rows.map((row) => (
        <tr key={row.id} className="border-slate-100 border-b dark:border-slate-900 ">
          {row.getVisibleCells().map((cell) => (
            <td key={cell.id} className={cn('px-3 py-4', (cell.column.columnDef.meta as ColumnMeta)?.cellClasses)}>
              {flexRender(cell.column.columnDef.cell, cell.getContext())}
            </td>
          ))}
        </tr>
      ))}
    </tbody>
  );
}
