"use client";
import DataTable from "@/components/ui/DataTable";

export default function Page(){
  const columns = [
    { key:"name", label:"Nome" },
    { key:"owner", label:"Responsável" },
    { key:"status", label:"Status" },
    { key:"updated", label:"Atualizado", align:"right" as const },
  ];
  const rows = [
    { name:"Projeto Alpha", owner:"Equipe A", status:"Ativo", updated:"2d" },
    { name:"Projeto Beta", owner:"Equipe B", status:"Em análise", updated:"5d" },
    { name:"Projeto Gama", owner:"Equipe C", status:"Concluído", updated:"9d" },
  ];
  return (
    <div className="section" style={{display:"grid", gap:16}}>
      <h1 className="h1">Projetos</h1>
      <DataTable columns={columns} rows={rows} />
    </div>
  );
}
