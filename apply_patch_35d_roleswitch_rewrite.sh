set -euo pipefail
echo "== Patch 35d: reescreve RoleSwitch limpo e tipado =="

mkdir -p components/ui
cat > components/ui/RoleSwitch.tsx <<'TSX'
"use client";

import { useEffect, useState, useCallback } from "react";

type Role = "admin" | "sponsor";

export default function RoleSwitch({
  value,
  onChange,
  className = "",
}: {
  value?: Role;
  onChange?: (r: Role) => void;
  className?: string;
}) {
  const [role, setRole] = useState<Role>(value ?? "admin");

  // Mantém estado interno sincronizado com prop controlada
  useEffect(() => {
    if (value && value !== role) setRole(value);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [value]);

  const onChangeCb = useCallback(
    (r: Role) => {
      setRole(r);
      if (onChange) onChange(r);
    },
    [onChange]
  );

  const isAdmin = role === "admin";

  return (
    <div
      className={[
        "relative w-[360px] h-14 p-1 rounded-2xl",
        "bg-[var(--surface)] border border-[var(--borderC)]",
        "shadow-[0_6px_24px_rgba(0,0,0,.06)]",
        "flex items-center gap-1 select-none",
        className,
      ].join(" ")}
      role="tablist"
      aria-label="Selecionar perfil"
    >
      {/* Slider */}
      <div
        className={[
          "absolute top-1 bottom-1 w-[calc(50%-6px)] rounded-xl",
          "transition-transform duration-300 will-change-transform",
          "bg-[var(--card)] shadow-[0_10px_30px_rgba(2,32,71,.12)]",
          isAdmin ? "translate-x-1" : "translate-x-[calc(100%+8px)]",
        ].join(" ")}
        aria-hidden="true"
      />

      <button
        type="button"
        onClick={() => onChangeCb("admin")}
        className={[
          "relative z-[1] flex-1 h-12 rounded-xl",
          "text-sm font-medium",
          isAdmin ? "text-[var(--text)]" : "text-[var(--muted)]",
          "transition-colors",
        ].join(" ")}
        aria-selected={isAdmin}
        role="tab"
      >
        Admin
      </button>

      <button
        type="button"
        onClick={() => onChangeCb("sponsor")}
        className={[
          "relative z-[1] flex-1 h-12 rounded-xl",
          "text-sm font-medium",
          !isAdmin ? "text-[var(--text)]" : "text-[var(--muted)]",
          "transition-colors",
        ].join(" ")}
        aria-selected={!isAdmin}
        role="tab"
      >
        Patrocinador
      </button>
    </div>
  );
}
TSX

echo "== Build =="
pnpm build
