"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { readSession, resolveBrandLogo } from "@/components/lib/session";

export default function Topbar(){
  const { role, brand } = readSession();
  const pathname = usePathname();

  const isSponsor = role === "sponsor";
  const sBase = brand ? `/sponsor/${brand}` : "/sponsor/acme";

  const items = isSponsor ? [
    { href: `${sBase}/overview`,   label: "Overview"    },
    { href: `${sBase}/results`,    label: "Resultados"  },
    { href: `${sBase}/financials`, label: "Financeiro"  },
    { href: `${sBase}/events`,     label: "Eventos"     },
    { href: `${sBase}/assets`,     label: "Assets"      },
    { href: `${sBase}/settings`,   label: "Settings"    },
  ] : [
    { href: "/",            label: "Overview" },
    { href: "/pipeline",    label: "Pipeline" },
    { href: "/projetos",    label: "Projetos" },
    { href: "/settings",    label: "Settings" },
  ];

  const onLogout = async ()=>{ try { await fetch("/api/logout", { method:"POST" }); } finally { window.location.href="/login"; } };

  return (
    <header className="glass">
      <div className="container flex items-center gap-3 h-[64px]">
        {/* Logo Engage (vai pra home admin) */}
        <Link href={isSponsor ? sBase+"/overview" : "/"} className="flex items-center gap-2">
          <span className="inline-flex h-8 w-8 rounded-lg bg-[var(--accent)]" />
          <span className="font-semibold">Engage</span>
        </Link>

        {/* Navegação principal */}
        <nav className="ml-4 hidden md:flex items-center gap-1">
          {items.map(it => {
            const active = pathname === it.href || pathname.startsWith(it.href);
            return (
              <Link key={it.href} href={it.href}
                className={`px-3 py-1.5 rounded-full border transition
                  ${active ? "bg-[var(--accent)] text-white border-transparent" : "bg-surface border-border hover:shadow-soft"}`}>
                {it.label}
              </Link>
            );
          })}
        </nav>

        <div className="ml-auto flex items-center gap-2">
          {/* Pílula do patrocinador (apenas logo → vai ao perfil/settings) */}
          {isSponsor && (
            <Link href={`${sBase}/settings`} className="flex items-center">
              <img src={resolveBrandLogo(brand)} alt="brand" width={40} height={40}
                   style={{borderRadius:10, display:"block"}} />
            </Link>
          )}
          {/* Logout */}
          <button onClick={onLogout} className="btn btn-outline">Sair</button>
        </div>
      </div>
    </header>
  );
}
