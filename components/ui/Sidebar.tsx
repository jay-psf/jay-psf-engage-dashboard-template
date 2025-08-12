"use client";
import Link from "next/link";
import { useEffect, useState } from "react";

export default function Sidebar() {
  const [role, setRole] = useState<"admin"|"sponsor">("admin");
  const [brand, setBrand] = useState("");

  useEffect(() => {
    const b = document.body;
    setRole((b.dataset.role as any) || "admin");
    setBrand(b.dataset.brand || "");
  }, []);

  const Item = ({ href, children }: { href: string; children: React.ReactNode }) => (
    <Link href={href} className="block px-4 py-3 rounded-xl border"
      style={{ borderColor:"var(--border)", background:"var(--panel)", color:"var(--text)" }}>
      {children}
    </Link>
  );

  return (
    <aside className="w-[260px] shrink-0">
      <div className="space-y-4">
        {role === "admin" && (
          <div>
            <div className="mb-2 text-sm" style={{ color:"var(--muted)" }}>Navegação</div>
            <div className="space-y-2">
              <Item href="/">Dashboard</Item>
              <Item href="/pipeline">Pipeline</Item>
              <Item href="/projetos">Projetos</Item>
              <Item href="/admin">Admin</Item>
            </div>
          </div>
        )}

        <div>
          <div className="mb-2 text-sm" style={{ color:"var(--muted)" }}>Patrocinador</div>
          <div className="space-y-2">
            <Item href={`/sponsor/${brand || "heineken"}/overview`}>Overview</Item>
            <Item href={`/sponsor/${brand || "heineken"}/results`}>Resultados</Item>
            <Item href={`/sponsor/${brand || "heineken"}/financials`}>Financeiro</Item>
          </div>
        </div>
      </div>
    </aside>
  );
}
