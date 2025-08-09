'use client';
import { useState } from "react";

export default function AdminPage() {
  const [modelo, setModelo] = useState("FEE_REV");
  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold">Admin (mock)</h2>
      <div className="card space-y-3">
        <div className="text-sm">Modelo de Comissionamento:</div>
        <div className="flex gap-2 text-sm">
          {["FEE_REV","EBIT_FEE","SPINOFF"].map((m)=>(
            <button key={m}
              className={`px-3 py-1 rounded border ${modelo===m ? 'bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900' : ''}`}
              onClick={()=>setModelo(m)}>{m}</button>
          ))}
        </div>
        <div className="text-xs opacity-70">Troca visual apenas (mock). Cálculo real entra depois.</div>
      </div>
    </div>
  );
}
