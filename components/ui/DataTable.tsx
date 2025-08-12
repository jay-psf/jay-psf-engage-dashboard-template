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
