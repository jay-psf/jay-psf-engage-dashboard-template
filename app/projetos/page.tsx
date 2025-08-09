'use client';
import { DataTable } from "../../components/DataTable";
import { useData } from "../../store/useData";

export default function ProjetosPage() {
  const { activationsColumns, activations } = useData();
  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold">Projetos & Ativações (mock)</h2>
      <DataTable columns={activationsColumns} data={activations} />
    </div>
  );
}
