set -euo pipefail
echo "== Patch 27: sponsor header sem sub-menu e logo 2x =="

mkdir -p components/sponsor
cat > components/sponsor/BrandHeader.tsx <<'TSX'
"use client";
/* eslint-disable @next/next/no-img-element */
import * as React from "react";

type Props = { brand?: string };

function brandFile(brand?: string) {
  const b = (brand || "acme").toLowerCase();
  return `/logos/${b}.png`;
}

/**
 * Header minimalista para páginas de sponsor.
 * - Sem sub-menu (evita duplicidade com o Topbar).
 * - Logo em 2x, com cápsula arredondada.
 */
export default function BrandHeader({ brand = "heineken" }: Props) {
  const [src, setSrc] = React.useState<string>(brandFile(brand));

  // Caso exista uma logo salva no localStorage (patch 29), usa-a.
  React.useEffect(() => {
    try {
      const k = `brandLogo:${brand.toLowerCase()}`;
      const v = window.localStorage.getItem(k);
      if (v) setSrc(v);
    } catch {}
  }, [brand]);

  return (
    <div className="flex items-center justify-between rounded-2xl border border-[var(--borderC)] bg-[var(--surface)] px-4 py-3 shadow-soft">
      <div className="flex items-center gap-3">
        <div
          className="flex items-center gap-2 rounded-full border border-[var(--borderC)] bg-[var(--card)] px-3 py-1.5"
          style={{ boxShadow: "0 0 0 8px rgba(126,58,242,.08)" }}
          aria-label="Patrocinador"
        >
          <img
            src={src}
            alt={brand}
            width={44}
            height={44}
            style={{ display: "block", borderRadius: 10, objectFit: "cover" }}
          />
        </div>
        <div className="leading-tight">
          <div className="text-sm text-[var(--muted)]">Patrocinador</div>
          <div className="text-lg font-semibold capitalize">{brand}</div>
        </div>
      </div>
      <div className="text-sm text-[var(--muted)]">
        {/* espaço para breadcrumbs futuramente, se necessário */}
      </div>
    </div>
  );
}
TSX

echo "== Build =="
pnpm -s build
