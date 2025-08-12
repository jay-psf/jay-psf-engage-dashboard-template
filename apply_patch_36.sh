set -euo pipefail
echo "== Patch 36: Glass Topbar + tipografia/respiração ajustadas + dark sólido =="

# 1) tokens mais contidos (tamanhos e contrastes) — não quebra variáveis existentes
mkdir -p styles
cat > styles/tokens.css <<'CSS'
:root{
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;

  /* Light */
  --bg:#F7F9FC; --card:#FFFFFF; --surface:#F2F4F9;
  --text:#0C1220; --muted:#667085; --borderC:rgba(16,24,40,.12);

  /* Dark (sólido) */
  --bg-dark:#0A0D14; --card-dark:#0C111A; --surface-dark:#0B1018;
  --text-dark:#E8EAF0; --muted-dark:#9AA4B2; --borderC-dark:rgba(255,255,255,.10);

  /* tipografia (um passo menor) */
  --fs-xs:12px; --fs-sm:13px; --fs-md:14.5px; --fs-lg:16px;
  --fs-h6:17px; --fs-h5:19px; --fs-h4:22px; --fs-h3:26px; --fs-h2:32px; --fs-h1:38px;

  /* espaçamento (8-based) */
  --space-1:4px; --space-2:8px; --space-3:12px; --space-4:16px; --space-5:20px;
  --space-6:24px; --space-8:32px; --space-10:40px; --space-12:48px;

  --container: 1200px;
  --radius:16px; --radius-lg:22px;
  --elev:0 10px 30px rgba(10,22,50,.08);
  --elev-dark:0 14px 36px rgba(0,0,0,.45);

  /* halos/glow sutis mas impactantes */
  --ring:rgba(126,58,242,.35);
  --ring-strong:rgba(126,58,242,.6);
}

:root[data-theme="dark"]{
  --bg:var(--bg-dark); --card:var(--card-dark); --surface:var(--surface-dark);
  --text:var(--text-dark); --muted:var(--muted-dark); --borderC:var(--borderC-dark);
}
CSS

# 2) globals de layout/respiração; cria styles/globals.css e um proxy app/globals.css
cat > styles/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

html,body{ background:var(--bg); color:var(--text); }

/* títulos mais contidos */
:where(h1){ font-size:var(--fs-h2); line-height:1.15; letter-spacing:-0.01em; font-weight:700; }
:where(h2){ font-size:var(--fs-h3); line-height:1.18; font-weight:700; }
:where(h3){ font-size:var(--fs-h4); line-height:1.2;  font-weight:600; }
:where(p,li,td,th){ font-size:var(--fs-md); }

/* container com respiro */
.page{ max-width:var(--container); margin:0 auto; padding: var(--space-6) var(--space-6) var(--space-10); }

/* cards */
.card{ background:var(--card); border:1px solid var(--borderC); border-radius:var(--radius); box-shadow:var(--elev); }
:root[data-theme="dark"] .card{ box-shadow:var(--elev-dark); }
.card-body{ padding:var(--space-6); }
.card-title{ font-size:var(--fs-h5); font-weight:600; margin-bottom:var(--space-3); }

/* tabela elegante */
.table{ width:100%; border-collapse:separate; border-spacing:0; background:var(--card); border:1px solid var(--borderC); border-radius:var(--radius); overflow:hidden; }
.table thead th{ text-align:left; font-weight:600; font-size:var(--fs-sm); color:var(--muted); background:var(--surface); padding:12px 16px; border-bottom:1px solid var(--borderC); position:sticky; top:0; z-index:1; }
.table tbody td{ padding:14px 16px; border-bottom:1px solid var(--borderC); }
.table tbody tr:nth-child(odd){ background: color-mix(in oklab, var(--surface) 55%, transparent); }
@supports not (background: color-mix(in oklab, #000 50%, #fff 50%)){ .table tbody tr:nth-child(odd){ background:var(--surface); } }

/* botões com glow sutil */
.btn{ display:inline-flex; align-items:center; justify-content:center; gap:8px; height:44px; padding:0 16px; border-radius:999px; border:1px solid var(--borderC); background:linear-gradient(180deg, var(--card), color-mix(in oklab, var(--card) 75%, transparent)); transition: transform .15s ease, box-shadow .2s ease, border-color .2s ease; }
.btn:hover{ transform: translateY(-1px); box-shadow:0 10px 30px rgba(126,58,242,.18), 0 0 0 8px color-mix(in oklab, var(--ring) 55%, transparent); border-color: color-mix(in oklab, var(--accent) 45%, var(--borderC)); }
.btn:active{ transform: translateY(0); }
.btn-primary{ background:linear-gradient(180deg, var(--accent), var(--accent-700)); color:white; border-color: transparent; }
.btn-primary:hover{ box-shadow: 0 12px 36px rgba(126,58,242,.26), 0 0 0 10px color-mix(in oklab, var(--ring-strong) 65%, transparent); }

.topbar-glass{
  position:sticky; top:0; z-index:40;
  background: color-mix(in oklab, var(--card) 65%, transparent);
  backdrop-filter: blur(10px);
  border-bottom:1px solid var(--borderC);
}
CSS

mkdir -p app
cat > app/globals.css <<'CSS'
@import "../styles/globals.css";
CSS

# 3) aplica container .page no ClientShell (se ainda não tiver)
if test -f components/ClientShell.tsx; then
  perl -0777 -pe 's/<main className="[^"]*">/<main className="page">/s' -i components/ClientShell.tsx || true
fi

# 4) Topbar reescrita com vidro, Image otimizando, navegação por papel e cliques nos logos
mkdir -p components/ui
cat > components/ui/Topbar.tsx <<'TSX'
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
TSX

# 5) RoleSwitch: corrige dependência do useEffect para calar o warning
if test -f components/ui/RoleSwitch.tsx; then
  # adiciona onChange nas deps do effect, de forma idempotente
  perl -0777 -pe 's/useEffect\(\(\) => \{([^}]*)\}, \[localRole\]\);/useEffect(() => {${1}}, [localRole, onChange]);/s' -i components/ui/RoleSwitch.tsx || true
fi

# 6) garante app/globals.css sendo importado por app/layout.tsx (caminho relativo)
if test -f app/layout.tsx; then
  if ! grep -q "globals.css" app/layout.tsx; then
    sed -i '1i import "./globals.css";' app/layout.tsx
  fi
fi

echo "== Build =="
pnpm build
