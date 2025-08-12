"use client";
import Link from "next/link";
import { useEffect, useState } from "react";

export default function Topbar() {
  const [role, setRole] = useState<"admin"|"sponsor">("admin");
  const [brand, setBrand] = useState<string>("");

  useEffect(() => {
    const body = document.body;
    setRole((body.dataset.role as any) || "admin");
    setBrand(body.dataset.brand || "");
  }, []);

  return (
    <header className="sticky top-0 z-40 w-full" style={{ background:"rgba(10,14,26,.75)", backdropFilter:"saturate(160%) blur(8px)" }}>
      <div className="max-w-screen-2xl mx-auto px-4 h-14 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-3 h-3 rounded" style={{ background:"var(--brand-accent)" }} />
          <span className="font-semibold">Engage Dashboard</span>
        </div>

        <div className="flex items-center gap-3">
          {role === "sponsor" && brand ? (
            <img src={`/logos/${brand}.svg`} alt={brand} className="h-7 rounded-lg border"
                 style={{ borderColor:"var(--border)" }}/>
          ) : (
            <span className="px-3 py-1 rounded-full text-sm" style={{ background:"var(--panel)", border:"1px solid var(--border)" }}>
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
