"use client";
import { useEffect, useState } from "react";
import clsx from "clsx";

type Props = {
  value?: "admin" | "sponsor";
  onChange?: (v:"admin"|"sponsor") => void;
};

export default function RoleSwitch({ value, onChange }: Props){
  const [role, setRole] = useState<"admin"|"sponsor">(value ?? "admin");
  useEffect(()=>{ onChange?.(role); },[role]);

  return (
    <div className={clsx(
      "pill lumen w-[360px] h-14 p-1 flex items-center gap-1",
      "bg-[var(--surface)]"
    )}>
      {(["admin","sponsor"] as const).map((k)=>(
        <button
          key={k}
          type="button"
          onClick={()=>setRole(k)}
          className={clsx(
            "flex-1 h-full rounded-[12px] transition-all",
            role===k ? "bg-[var(--card)] text-[var(--text)] shadow"
                     : "text-[var(--muted)]"
          )}
        >
          <div className="h-full grid place-items-center text-sm font-medium">
            {k==="admin" ? "Interno (Admin)" : "Patrocinador"}
          </div>
        </button>
      ))}
      <style jsx>{`
        .shadow{
          box-shadow:
            0 1px 0 rgba(0,0,0,.06),
            inset 0 0 0 1px var(--borderC);
        }
      `}</style>
    </div>
  );
}
