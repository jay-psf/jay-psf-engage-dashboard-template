set -euo pipefail

echo "== Patch 12 (sem Python): tokens, Topbar, Sidebar, dark cards =="

# 1) Tokens (light/dark com superfícies realmente escuras)
cat > styles/tokens.css <<'CSS'
:root {
  /* Cores - Light */
  --accent: #7E3AF2;
  --accent-600: #6C2BD9;
  --accent-700: #5B21B6;

  --bg: #F6F8FB;
  --card: #FFFFFF;
  --surface: #F2F4F9;

  --text: #0B1524;
  --muted: #667085;

  --borderC: rgba(16,24,40,0.12);
  --ring: rgba(126, 58, 242, .40);

  /* Raios */
  --radius-xs: 6px;
  --radius-sm: 8px;
  --radius: 12px;
  --radius-lg: 16px;
  --radius-xl: 20px;

  /* Sombras */
  --shadow-soft: 0 8px 30px rgba(2, 32, 71, .08);
  --shadow-elev: 0 12px 42px rgba(2, 32, 71, .10);
}

:root[data-theme="dark"] {
  /* Cores - Dark (sponsor) */
  --accent: #A78BFA;
  --accent-600: #8B5CF6;
  --accent-700: #7C3AED;

  --bg: #0A0F1A;
  --card: #0D1320;
  --surface: #0B111C;

  --text: #E6E8EC;
  --muted: #9BA3AF;

  --borderC: rgba(255,255,255,0.10);
  --ring: rgba(167,139,250,.45);

  --shadow-soft: 0 10px 28px rgba(0,0,0,.40);
  --shadow-elev: 0 16px 48px rgba(0,0,0,.50);
}

/* Utilitários */
html, body { background: var(--bg); color: var(--text); }

.bg-card     { background: var(--card); }
.bg-surface  { background: var(--surface); }
.text-muted  { color: var(--muted); }
.border      { border: 1px solid var(--borderC); }
.border-border { border-color: var(--borderC); }
.rounded-xs { border-radius: var(--radius-xs); }
.rounded-sm { border-radius: var(--radius-sm); }
.rounded-xl { border-radius: var(--radius); }
.rounded-2xl { border-radius: var(--radius-lg); }
.rounded-3xl { border-radius: var(--radius-xl); }
.shadow-soft { box-shadow: var(--shadow-soft); }
.shadow-elev { box-shadow: var(--shadow-elev); }

/* Foco visível */
:where(button,a,[role="button"],input,select,textarea):focus-visible {
  outline: none;
  box-shadow: 0 0 0 4px var(--ring);
}

/* Sidebar mobile */
@media (max-width: 767px) {
  .SidebarMobile {
    position: fixed; inset: 0 auto 0 0; width: 18rem; height: 100%;
    transform: translateX(-100%);
    transition: transform .25s ease, opacity .25s ease;
    opacity: 0; pointer-events: none;
    background: var(--card);
    box-shadow: var(--shadow-elev);
    z-index: 70;
  }
  html[data-sidebar="open"] .SidebarMobile {
    transform: translateX(0%); opacity: 1; pointer-events: auto;
  }
  .SidebarScrim {
    position: fixed; inset: 0;
    background: rgba(0,0,0,.45);
    opacity: 0; pointer-events: none;
    transition: opacity .25s ease;
    z-index: 60;
  }
  html[data-sidebar="open"] .SidebarScrim {
    opacity: 1; pointer-events: auto;
  }
}
CSS

# 2) Topbar refeito (hamburger + só o logo do brand)
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import { readSession } from "@/components/lib/session";

export default function Topbar() {
  const [{ role, brand }, setSession] = useState<{role?: "admin"|"sponsor"; brand?: string}>({});

  useEffect(() => {
    setSession(readSession());
  }, []);

  function toggleSidebar() {
    const html = document.documentElement;
    const cur = html.getAttribute("data-sidebar");
    html.setAttribute("data-sidebar", cur === "open" ? "closed" : "open");
  }

  async function logout() {
    await fetch("/api/logout", { method: "POST" });
    window.location.href = "/login";
  }

  return (
    <header className="sticky top-0 z-40 bg-surface/80 backdrop-blur border-b border-border">
      <div className="mx-auto max-w-screen-2xl px-4 py-3 flex items-center gap-3">
        {/* Hamburger mobile */}
        <button
          aria-label="Abrir menu"
          onClick={toggleSidebar}
          className="md:hidden inline-flex items-center gap-2 rounded-xl border border-border bg-card px-3 py-2"
        >
          <span style={{width:20,height:2,background:"currentColor",display:"block",borderRadius:2}} />
          <span style={{width:20,height:2,background:"currentColor",display:"block",borderRadius:2,marginTop:3}} />
          <span style={{width:20,height:2,background:"currentColor",display:"block",borderRadius:2,marginTop:3}} />
        </button>

        <Link href="/" className="mr-auto font-semibold">Engage</Link>

        {/* Pílula com apenas o logo do brand (se sponsor) */}
        {role === "sponsor" && (
          <div className="rounded-2xl border border-border bg-card px-3 py-1.5 flex items-center gap-2">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={`/logos/${brand ?? "acme"}.png`}
              alt={brand ?? "brand"}
              width={22}
              height={22}
              className="brand-logo"
              style={{ borderRadius: 6, display: "block" }}
            />
          </div>
        )}

        <button onClick={logout} className="ml-2 rounded-xl border border-border bg-card px-4 py-2">
          Sair
        </button>
      </div>
    </header>
  );
}
TSX

# 3) Sidebar com suporte mobile (scrim + drawer)
cat > components/ui/Sidebar.tsx <<'TSX'
"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import { readSession } from "@/components/lib/session";

function NavItem({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link
      href={href}
      className="block rounded-2xl border border-border bg-card px-4 py-3 transition hover:shadow-soft"
      onClick={() => document.documentElement.setAttribute("data-sidebar", "closed")}
    >
      {children}
    </Link>
  );
}

export default function Sidebar() {
  const [{ role, brand }, setSession] = useState<{role?: "admin"|"sponsor"; brand?: string}>({});

  useEffect(() => {
    setSession(readSession());
  }, []);

  return (
    <>
      {/* Scrim mobile */}
      <div className="SidebarScrim md:hidden" onClick={() => document.documentElement.setAttribute("data-sidebar", "closed")} />

      {/* Drawer mobile */}
      <aside className="SidebarMobile md:hidden p-4 space-y-3 border border-border">
        {role === "sponsor" ? (
          <>
            <NavItem href={`/sponsor/${brand}/overview`}>Overview</NavItem>
            <NavItem href={`/sponsor/${brand}/results`}>Resultados</NavItem>
            <NavItem href={`/sponsor/${brand}/financials`}>Financeiro</NavItem>
            <NavItem href={`/sponsor/${brand}/events`}>Eventos</NavItem>
            <NavItem href={`/sponsor/${brand}/assets`}>Assets</NavItem>
            <NavItem href={`/sponsor/${brand}/settings`}>Settings</NavItem>
          </>
        ) : (
          <>
            <NavItem href="/">Overview</NavItem>
            <NavItem href="/projetos">Resultados</NavItem>
            <NavItem href="/pipeline">Financeiro</NavItem>
            <NavItem href="/settings">Settings</NavItem>
          </>
        )}
      </aside>

      {/* Sidebar desktop */}
      <aside className="hidden md:block w-[260px]">
        <div className="p-4 space-y-3">
          {role === "sponsor" ? (
            <>
              <NavItem href={`/sponsor/${brand}/overview`}>Overview</NavItem>
              <NavItem href={`/sponsor/${brand}/results`}>Resultados</NavItem>
              <NavItem href={`/sponsor/${brand}/financials`}>Financeiro</NavItem>
              <NavItem href={`/sponsor/${brand}/events`}>Eventos</NavItem>
              <NavItem href={`/sponsor/${brand}/assets`}>Assets</NavItem>
              <NavItem href={`/sponsor/${brand}/settings`}>Settings</NavItem>
            </>
          ) : (
            <>
              <NavItem href="/">Overview</NavItem>
              <NavItem href="/projetos">Resultados</NavItem>
              <NavItem href="/pipeline">Financeiro</NavItem>
              <NavItem href="/settings">Settings</NavItem>
            </>
          )}
        </div>
      </aside>
    </>
  );
}
TSX

# 4) Força bg-card nos cards do sponsor (acabam caixas brancas no dark)
if ls app/sponsor/*/*.tsx >/dev/null 2>&1; then
  for f in app/sponsor/*/*.tsx; do
    sed -i.bak 's/className="rounded-2xl border /className="rounded-2xl border bg-card /g' "$f" || true
    rm -f "$f.bak"
  done
fi

echo "== Build =="
pnpm build

echo "== Patch 12 aplicado com sucesso =="
