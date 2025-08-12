"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import Button from "@/components/ui/Button";
import { readSession, clearSessionAndGoLogin } from "@/components/lib/session";

function brandLogo(brand?: string){
  const b = (brand || "acme").toLowerCase();
  return `/logos/${b}.png`;
}

export default function Topbar(){
  const { role, brand } = readSession();
  const pathname = usePathname();

  const isSponsor = role === "sponsor";
  const base = "/";
  const sBase = brand ? `/sponsor/${brand}` : "/sponsor/acme";

  const items = isSponsor ? [
    { href: `${sBase}/overview`,   label: "Overview",   active: pathname.startsWith(`${sBase}/overview`) },
    { href: `${sBase}/results`,    label: "Resultados", active: pathname.startsWith(`${sBase}/results`) },
    { href: `${sBase}/financials`, label: "Financeiro", active: pathname.startsWith(`${sBase}/financials`) },
    { href: `${sBase}/events`,     label: "Eventos",    active: pathname.startsWith(`${sBase}/events`) },
    { href: `${sBase}/assets`,     label: "Assets",     active: pathname.startsWith(`${sBase}/assets`) },
    { href: `${sBase}/settings`,   label: "Settings",   active: pathname.startsWith(`${sBase}/settings`) },
  ] : [
    { href: `${base}`,         label: "Dashboard",  active: pathname === base },
    { href: `/pipeline`,      label: "Pipeline",    active: pathname.startsWith(`/pipeline`) },
    { href: `/projetos`,      label: "Projetos",    active: pathname.startsWith(`/projetos`) },
    { href: `/settings`,      label: "Settings",    active: pathname.startsWith(`/settings`) },
  ];

  const onLogout = async () => {
    try { await fetch("/api/logout", { method: "POST" }); } catch {}
    clearSessionAndGoLogin();
  };

  return (
    <header className="sticky top-0 z-30 backdrop-blur supports-[backdrop-filter]:bg-[color-mix(in_oklab,var(--bg)_70%,transparent)]">
      <div className="mx-auto max-w-screen-2xl flex items-center gap-4 px-4 py-3">
        {/* Logo Engage à esquerda */}
        <Link href={isSponsor ? `${sBase}/overview` : "/"} className="flex items-center gap-2">
          <div className="w-7 h-7 rounded-xl bg-[var(--accent)]" />
          <span className="font-semibold">Engage</span>
        </Link>

        {/* Navegação superior */}
        <nav className="ml-2 flex flex-wrap gap-2">
          {items.map(it=>(
            <Link key={it.href} href={it.href} className={["pill", it.active ? "active" : ""].join(" ")}>
              {it.label}
            </Link>
          ))}
        </nav>

        <div className="ml-auto flex items-center gap-3">
          {/* Chip do sponsor apenas com logo (sem texto), 2x maior e com borda arredondada */}
          {isSponsor && (
            <div className="flex items-center gap-2 rounded-2xl border border-border bg-card px-2.5 py-1.5 shadow-soft">
              <img
                src={brandLogo(brand)} alt={brand ?? "brand"}
                width="44" height="44"
                style={{ borderRadius: 12, display: "block", objectFit: "cover" }}
              />
            </div>
          )}

          <Button variant="outline" onClick={onLogout} className="glow-iris">Sair</Button>
        </div>
      </div>
    </header>
  );
}
