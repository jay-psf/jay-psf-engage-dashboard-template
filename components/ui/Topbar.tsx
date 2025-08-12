"use client";
import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { readSession } from "@/components/lib/session";

export default function Topbar(){
  const pathname = usePathname();
  const { role, brand } = readSession() || {};

  const isSponsor = role === "sponsor";
  const sBase = brand ? `/sponsor/${brand}` : "/sponsor/acme";

  const adminNav = [
    { href: "/admin",       label: "Overview",   active: pathname === "/admin" },
    { href: "/pipeline",    label: "Pipeline",   active: pathname.startsWith("/pipeline") },
    { href: "/projetos",    label: "Projetos",   active: pathname.startsWith("/projetos") },
    { href: "/settings",    label: "Settings",   active: pathname.startsWith("/settings") },
  ];
  const sponsorNav = [
    { href: `${sBase}/overview`,   label: "Overview",   active: pathname.startsWith(`${sBase}/overview`) || pathname === sBase },
    { href: `${sBase}/results`,    label: "Resultados", active: pathname.startsWith(`${sBase}/results`) },
    { href: `${sBase}/financials`, label: "Financeiro", active: pathname.startsWith(`${sBase}/financials`) },
    { href: `${sBase}/events`,     label: "Eventos",    active: pathname.startsWith(`${sBase}/events`) },
    { href: `${sBase}/assets`,     label: "Assets",     active: pathname.startsWith(`${sBase}/assets`) },
    { href: `${sBase}/settings`,   label: "Settings",   active: pathname.startsWith(`${sBase}/settings`) },
  ];
  const items = isSponsor ? sponsorNav : adminNav;

  const onLogout = async () => {
    try { await fetch("/api/logout", { method:"POST" }); }
    finally { window.location.href = "/login"; }
  };

  return (
    <div className="topbar-glass">
      <div className="mx-auto flex h-[64px] w-full max-w-screen-2xl items-center justify-between px-5">
        {/* ESQUERDA: logo Engage (home) + navegação */}
        <div className="flex items-center gap-6">
          <Link href="/" className="flex items-center gap-2 pr-2">
            <Image src="/engage-logo.svg" alt="Engage" width={24} height={24} priority />
            <span className="font-semibold tracking-[-0.01em]">Engage</span>
          </Link>

          <nav className="hidden md:flex items-center gap-2">
            {items.map((it)=>(
              <Link
                key={it.href}
                href={it.href}
                className={`px-3 py-2 rounded-full border transition
                  ${it.active
                    ? "border-[var(--accent)] text-[var(--accent)] bg-[color-mix(in_oklab,var(--accent)_12%,transparent)]"
                    : "border-transparent text-[var(--muted)] hover:text-[var(--text)] hover:bg-[var(--surface)]"
                  }`}
              >
                {it.label}
              </Link>
            ))}
          </nav>
        </div>

        {/* DIREITA: logo do patrocinador (só o logo) + logout */}
        <div className="flex items-center gap-3">
          {isSponsor && (
            <Link href={`${sBase}/overview`} className="flex items-center">
              <Image
                src={`/logos/${(brand||"acme").toLowerCase()}.png`}
                alt={brand || "brand"}
                width={44}
                height={44}
                style={{ borderRadius: 10, objectFit:"contain" }}
              />
            </Link>
          )}
          <button onClick={onLogout} className="btn">Sair</button>
        </div>
      </div>
    </div>
  );
}
