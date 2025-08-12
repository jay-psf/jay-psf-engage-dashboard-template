"use client";
import Link from "next/link";
import { useEffect, useState } from "react";

export default function Topbar() {
  const [role, setRole] = useState<"admin"|"sponsor">("admin");
  const [brand, setBrand] = useState("");

  useEffect(() => {
    const b = document.body;
    setRole((b.dataset.role as any) || "admin");
    setBrand(b.dataset.brand || "");
  }, []);

  // simples mapeamento de arquivo por marca
  const brandSrc =
    role === "sponsor" && brand
      ? (brand === "heineken" ? "/logos/heineken.jpeg" : `/logos/${brand}.svg`)
      : null;

  return (
    <header className="sticky top-0 z-40 w-full"
      style={{ background:"rgba(10,14,26,.75)", backdropFilter:"saturate(160%) blur(8px)", borderBottom:"1px solid var(--border)" }}>
      <div className="max-w-screen-2xl mx-auto px-4 h-14 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-3 h-3 rounded" style={{ background:"var(--brand-accent)" }} />
          <span className="font-semibold">Engage Dashboard</span>
        </div>

        <div className="flex items-center gap-3">
          {brandSrc ? (
            <img src={brandSrc} alt={brand} className="h-7 rounded-lg border" style={{ borderColor:"var(--border)" }}/>
          ) : (
            <span className="px-3 py-1 rounded-full text-sm"
              style={{ background:"var(--panel)", border:"1px solid var(--border)", color:"var(--text)" }}>
              Engage (interno)
            </span>
          )}
          <Link href="/api/logout" className="px-3 py-1 rounded-full text-sm"
            style={{ background:"transparent", border:"1px solid var(--border)", color:"var(--text)" }}>
            Sair
          </Link>
        </div>
      </div>
    </header>
  );
}
