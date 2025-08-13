"use client";
import { useEffect, useState, useCallback } from "react";
import clsx from "clsx";

type Props = {
  value?: "admin" | "sponsor";
  onChange?: (r: "admin" | "sponsor") => void;
  className?: string;
};

export default function RoleSwitch({ value="admin", onChange, className }: Props){
  const [role, setRole] = useState<"admin"|"sponsor">(value);
  const onChangeCb = useCallback((r: "admin"|"sponsor") => { onChange?.(r); }, [onChange]);

  useEffect(() => { onChangeCb(role); }, [role, onChangeCb]);

  return (
    <div className={clsx("pill lumen w-[360px] h-14 p-1 flex items-center gap-1", className)}>
      <button
        className={clsx(
          "flex-1 h-12 rounded-[12px] transition",
          role === "admin" ? "bg-[var(--accent)] text-white shadow-[var(--halo)]" : "text-[var(--text)] hover:bg-[var(--surface)]"
        )}
        onClick={() => setRole("admin")}
      >
        Admin
      </button>
      <button
        className={clsx(
          "flex-1 h-12 rounded-[12px] transition",
          role === "sponsor" ? "bg-[var(--accent)] text-white shadow-[var(--halo)]" : "text-[var(--text)] hover:bg-[var(--surface)]"
        )}
        onClick={() => setRole("sponsor")}
      >
        Patrocinador
      </button>
    </div>
  );
}
