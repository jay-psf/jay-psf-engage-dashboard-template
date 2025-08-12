set -euo pipefail
echo "== Patch 45: Botões com glow gradiente sutil =="

mkdir -p components/ui
cat > components/ui/Button.tsx <<'TSX'
"use client";

import React from "react";

type Variant = "primary" | "outline" | "ghost";
type Size = "sm" | "md";
type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: Variant; size?: Size;
};

export default function Button({variant="primary", size="md", className="", style, ...rest}:Props){
  const base: React.CSSProperties = {
    borderRadius: 12,
    border: "1px solid var(--borderC)",
    transition: "transform .08s ease, box-shadow .12s ease, background .12s ease",
    padding: size==="sm" ? "8px 12px" : "10px 16px",
    fontSize: size==="sm" ? "13px" : "14px",
    background: "var(--card)"
  };

  const v: Record<Variant, React.CSSProperties> = {
    primary: {
      background: "linear-gradient(180deg, #8B5CF6 0%, #7C3AED 100%)",
      color: "white",
      border: "1px solid #6D28D9",
      boxShadow: "0 6px 16px rgba(124,58,237,.25)"
    },
    outline: { background:"transparent" },
    ghost: { background:"transparent", border:"1px solid transparent" }
  };

  const hover: React.CSSProperties =
    variant==="primary"
      ? { boxShadow: "0 10px 28px rgba(124,58,237,.36)" }
      : { boxShadow: "0 8px 22px rgba(2,32,71,.10)" };

  return (
    <button
      {...rest}
      className={"focus-ring "+className}
      style={{ ...base, ...v[variant], ...style }}
      onMouseEnter={(e)=>{ (e.currentTarget as HTMLButtonElement).style.transform = "translateY(-1px)"; (e.currentTarget as HTMLButtonElement).style.boxShadow = hover.boxShadow!; }}
      onMouseLeave={(e)=>{ (e.currentTarget as HTMLButtonElement).style.transform = "translateY(0)"; (e.currentTarget as HTMLButtonElement).style.boxShadow = v[variant].boxShadow || base.boxShadow || ""; }}
      onMouseDown={(e)=>{ (e.currentTarget as HTMLButtonElement).style.transform = "translateY(0) scale(.98)"; }}
      onMouseUp={(e)=>{ (e.currentTarget as HTMLButtonElement).style.transform = "translateY(-1px)"; }}
    />
  );
}
TSX

echo "== Build =="
pnpm build
