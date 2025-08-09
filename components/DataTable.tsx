'use client';
import { ColumnDef, flexRender, getCoreRowModel, useReactTable } from "@tanstack/react-table";

export function DataTable<T>({ columns, data }:{ columns: ColumnDef<T, any>[]; data: T[]; }){
  const table = useReactTable({ data, columns, getCoreRowModel: getCoreRowModel() });
  return (
    <div className="overflow-auto border border-neutral-200 dark:border-neutral-800 rounded-xl">
      <table className="w-full text-sm">
        <thead className="bg-neutral-100 dark:bg-neutral-900/40">
          {table.getHeaderGroups().map(hg=>(
            <tr key={hg.id}>
              {hg.headers.map(h=>(
                <th key={h.id} className="text-left p-2 font-medium">
                  {h.isPlaceholder ? null : flexRender(h.column.columnDef.header, h.getContext())}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map(r=>(
            <tr key={r.id} className="border-t border-neutral-200 dark:border-neutral-800">
              {r.getVisibleCells().map(c=>(
                <td key={c.id} className="p-2">{flexRender(c.column.columnDef.cell, c.getContext())}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
