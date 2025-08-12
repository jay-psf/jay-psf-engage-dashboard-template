set -euo pipefail
echo "== Patch 32: Topbar 'glass' fixa + navegação superior unificada =="

# 1) Tokens: acrescenta utilitários de vidro/blur e alguns helpers
mkdir -p styles
cat > styles/tokens.css <<'CSS'
:root{
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;

  /* Light */
  --bg:#F6F8FB; --card:#FFFFFF; --surface:#F2F4F9;
  --text:#0B1524; --muted:#667085; --borderC:rgba(16,24,40,.12);

  /* Dark */
  --bg-dark:#0B1220; --card-dark:#0F1627; --surface-dark:#0C1322;
  --text-dark:#E6E8EC; --muted-dark:#9BA3AF; --borderC-dark:rgba(255,255,255,.10);

  /* Vidro / Halo / Sombra */
  --glass: rgba(255,255,255,.65);
  --glass-border: rgba(16,24,40,.12);
  --glass-shadow: 0 6px 30px rgba(2,32,71,.10);
  --glass-dark: rgba(15,22,39,.55);
  --glass-border-dark: rgba(255,255,255,.10);
  --glass-shadow-dark: 0 10px 36px rgba(0,0,0,.35);

  --ring: rgba(126,58,242,.40);
  --ring-strong: rgba(126,58,242,.65);

  --radius: 16px; --radius-lg: 22px;
}

:root[data-theme="dark"]{
  --bg:var(--bg-dark);
  --card:var(--card-dark);
  --surface:var(--surface-dark);
  --text:var(--text-dark);
  --muted:var(--muted-dark);
  --borderC:var(--borderC-dark);
}

/* Base + grade sutil no fundo */
html,body{ background:var(--bg); color:var(--text); min-height:100%; }

.glass{
  background: var(--glass);
  border: 1px solid var(--glass-border);
  box-shadow: var(--glass-shadow);
  -webkit-backdrop-filter: saturate(140%) blur(14px);
  backdrop-filter: saturate(140%) blur(14px);
}
:root[data-theme="dark"] .glass{
  background: var(--glass-dark);
  border-color: var(--glass-border-dark);
  box-shadow: var(--glass-shadow-dark);
}

/* Botões e nav pills simplificados (só para o topo) */
.nav-pill{
  display:inline-flex; align-items:center; gap:.5rem;
  padding:.56rem 1.05rem; border-radius:999px; border:1px solid var(--borderC);
  background: transparent; color:var(--text); text-decoration:none;
  transition: transform .15s ease, box-shadow .15s ease, background .15s ease;
}
.nav-pill:hover{ transform: translateY(-1px); box-shadow: 0 6px 24px rgba(2,32,71,.10); }
:root[data-theme="dark"] .nav-pill:hover{ box-shadow: 0 10px 30px rgba(0,0,0,.35); }
.nav-pill.active{ background: var(--accent); color: #fff; border-color: transparent; }

.btn{
  display:inline-flex; align-items:center; justify-content:center; gap:.5rem;
  padding:.56rem 1rem; border-radius:999px; border:1px solid var(--borderC);
  background: #fff; color:#111;
  transition: transform .15s ease, box-shadow .15s ease, background .15s ease;
}
:root[data-theme="dark"] .btn{ background:#0F1627; color:#E6E8EC; }
.btn:hover{ box-shadow: 0 0 0 8px var(--ring); transform: translateY(-1px); }
.btn-primary{ background: var(--accent); color:#fff; border-color:transparent; }
.btn-outline{ background: transparent; color: var(--text); }

.topbar-spacer{ height: 72px; } /* reserva para topbar fixa */
CSS

# 2) Topbar “glass” fixa + navegação superior unificada
mkdir -p components/ui
cat > components/ui/Topbar.tsx <<'TSX'
"use client";

import Link from "next/link";
import Image from "next/image";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";

type Role = "admin" | "sponsor";

function readCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  const escaped = name.replace(/([.$?*|{}()[\]\\/+^])/g, "\\$1");
  const re = new RegExp("(?:^|; )" + escaped + "=([^;]*)");
  const m = document.cookie.match(re);
  return m ? decodeURIComponent(m[1]) : undefined;
}

function brandLogo(brand?: string) {
  const b = (brand || "heineken").toLowerCase();
  return `/logos/${b}.png`;
}

export default function Topbar() {
  const pathname = usePathname();
  const router = useRouter();
  const [role, setRole] = useState<Role | undefined>();
  const [brand, setBrand] = useState<string | undefined>();

  useEffect(() => {
    setRole((readCookie("role") as Role) || undefined);
    setBrand(readCookie("brand") || undefined);
  }, []);

  const isAdmin = role === "admin";
  const sponsorBase = brand ? `/sponsor/${brand}` : "/sponsor/heineken";

  const links = useMemo(() => {
    if (isAdmin) {
      return [
        { href: "/", label: "Dashboard" },
        { href: "/pipeline", label: "Pipeline" },
        { href: "/projetos", label: "Projetos" },
        { href: "/settings", label: "Settings" },
      ];
    }
    return [
      { href: `${sponsorBase}/overview`, label: "Overview" },
      { href: `${sponsorBase}/results`, label: "Resultados" },
      { href: `${sponsorBase}/financials`, label: "Financeiro" },
      { href: `${sponsorBase}/events`, label: "Eventos" },
      { href: `${sponsorBase}/assets`, label: "Assets" },
      { href: `${sponsorBase}/settings`, label: "Settings" },
    ];
  }, [isAdmin, sponsorBase]);

  const logout = async () => {
    try { await fetch("/api/logout",{method:"POST"}); } catch {}
    router.push("/login");
  };

  return (
    <div className="fixed inset-x-0 top-0 z-50">
      <div
        className="glass mx-auto mt-3 flex h-[64px] w-[min(1240px,96%)] items-center justify-between rounded-[18px] px-4"
        style={{ borderRadius: 18 }}
      >
        <div className="flex items-center gap-3">
          <Link href={isAdmin ? "/" : `${sponsorBase}/overview`} className="nav-pill active" aria-label="Engage">
            <span style={{ fontWeight: 700 }}>Engage</span>
          </Link>
          <nav className="hidden gap-2 md:flex">
            {links.map((l) => {
              const active = pathname === l.href || pathname.startsWith(l.href + "/");
              return (
                <Link key={l.href} href={l.href} className={`nav-pill ${active ? "active" : ""}`}>
                  {l.label}
                </Link>
              );
            })}
          </nav>
        </div>

        <div className="flex items-center gap-2">
          {role === "sponsor" && (
            <div className="nav-pill" style={{ paddingRight: 12, paddingLeft: 8 }}>
              <Image
                src={brandLogo(brand)}
                alt={brand ?? "brand"}
                width={28}
                height={28}
                style={{ display:"block", borderRadius: 8, objectFit:"cover" }}
              />
            </div>
          )}
          <button className="btn btn-outline" onClick={logout}>Sair</button>
        </div>
      </div>
    </div>
  );
}
TSX

# 3) Shell do app: remove o sidebar e reserva espaço para a topbar fixa
mkdir -p components
cat > components/ClientShell.tsx <<'TSX'
"use client";

import { ReactNode, useEffect, useState } from "react";
import Topbar from "@/components/ui/Topbar";

type ThemePref = "light" | "dark" | "system";

export default function ClientShell({ children }: { children: ReactNode }) {
  const [ready, setReady] = useState(false);

  useEffect(() => {
    // Aplica tema escolhido (localStorage: themePref)
    const p = localStorage.getItem("themePref") as ThemePref | null;
    if (p === "dark") document.documentElement.setAttribute("data-theme", "dark");
    else if (p === "light") document.documentElement.removeAttribute("data-theme");
    else {
      // system
      const mm = window.matchMedia("(prefers-color-scheme: dark)");
      const apply = () =>
        document.documentElement.toggleAttribute("data-theme", mm.matches);
      apply(); mm.addEventListener("change", apply);
    }
    setReady(true);
  }, []);

  return (
    <>
      <Topbar />
      <div className="topbar-spacer" />
      <main className="mx-auto w-[min(1240px,96%)] pb-10">
        {children}
      </main>
    </>
  );
}
TSX

# 4) Layout: usa o ClientShell acima (mantém páginas existentes)
mkdir -p app
cat > app/layout.tsx <<'TSX'
import "./globals.css";
import "@/styles/tokens.css";
import ClientShell from "@/components/ClientShell";
import type { ReactNode } from "react";

export const metadata = {
  title: "Engage",
  description: "Entourage • Engage Dashboard",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="pt-BR">
      <body>
        <ClientShell>{children}</ClientShell>
      </body>
    </html>
  );
}
TSX

echo "== Build =="
pnpm build
