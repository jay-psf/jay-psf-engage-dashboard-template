set -euo pipefail
echo "== Patch 44: DataTable estilizada =="

mkdir -p components/ui
cat > components/ui/DataTable.tsx <<'TSX'
"use client";

type Col = { key: string; label: string; width?: number|string; align?: "left"|"right"|"center" };
type Props = { columns: Col[]; rows: Record<string, any>[] };

export default function DataTable({columns, rows}:Props){
  return (
    <div className="card" style={{overflow:"auto"}}>
      <table style={{width:"100%", borderCollapse:"separate", borderSpacing:0}}>
        <thead className="glass" style={{position:"sticky", top:0}}>
          <tr>
            {columns.map(c=>(
              <th key={c.key} style={{
                textAlign: c.align||"left",
                padding:"12px 14px",
                fontSize:12, letterSpacing:".02em", textTransform:"uppercase",
                borderBottom:"1px solid var(--borderC)", width: c.width
              }}>{c.label}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((r,i)=>(
            <tr key={i} style={{background: i%2? "var(--surface)" : "transparent"}}>
              {columns.map(c=>(
                <td key={c.key} style={{padding:"12px 14px", textAlign:c.align||"left", borderBottom:"1px solid var(--borderC)"}}>
                  {String(r[c.key] ?? "")}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
TSX

seed_page () {
  local file="$1"; local title="$2"
  cat > "$file" <<TSX
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
      <h1 className="h1">$title</h1>
      <DataTable columns={columns} rows={rows} />
    </div>
  );
}
TSX
}

# 2) Popular /pipeline e /projetos (apenas se existirem ou criar gentilmente)
mkdir -p app/pipeline
seed_page app/pipeline/page.tsx "Pipeline"

mkdir -p app/projetos
seed_page app/projetos/page.tsx "Projetos"

echo "== Build =="
pnpm build
