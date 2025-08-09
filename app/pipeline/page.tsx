'use client';
import { DataTable } from "../../components/DataTable";
import { useData } from "../../store/useData";

export default function PipelinePage() {
  const { opportunitiesColumns, opportunities } = useData();
  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold">Pipeline (mock)</h2>
      <DataTable columns={opportunitiesColumns} data={opportunities} />
    </div>
  );
}
