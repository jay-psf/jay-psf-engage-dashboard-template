# === DESIGN & UX PATCH: tema sem flicker, topbar com avatar/logo, settings, e estética ===
cd /workspaces/jay-psf-engage-dashboard-template || exit 2

# 0) Tokens — ajusta contraste e arredondamentos
apply_tokens() {
  cat > styles/tokens.css <<'CSS'
:root {
  /* Entourage-like light */
  --accent: #00A7DD;
  --bg: #F5F7FA;
  --card: #FFFFFF;
  --surface: #FAFBFF;
  --text: #0B1524;
  --muted: #667085;
  --borderC: rgba(16,24,40,0.10);
  --ring: rgba(0,167,221,.35);

  --radius: 16px;
  --radius-lg: 20px;
  --elev: 0 10px 30px rgba(2,32,71,.08);
}
:root[data-theme="dark"] {
  /* Sponsor dark */
  --accent: #00A7DD;
  --bg: #0B1220;
  --card: #0F1627;
  --surface: #0C1322;
  --text: #E6E8EC;
  --muted: #9BA3AF;
  --borderC: rgba(255,255,255,0.10);
  --ring: rgba(0,167,221,.50);
  --elev: 0 14px 36px rgba(0,0,0,.35);
}

/* utilidades */
* { border-color: color-mix(in oklab, currentColor 18%, transparent); }
html, body { background: var(--bg); color: var(--text); }
.bg-card { background: var(--card); }
.bg-surface { background: var(--surface); }
.border { border: 1px solid var(--borderC); }
.text-muted { color: var(--muted); }
.shadow-soft { box-shadow: var(--elev); }
.rounded-xl { border-radius: var(--radius); }
.rounded-2xl { border-radius: var(--radius-lg); }

/* inputs coerentes */
.input {
  height: 48px;
  width: 100%;
  border: 1px solid var(--borderC);
  background: var(--surface);
  border-radius: var(--radius);
  padding: 0 12px;
  outline: none;
  transition: box-shadow .15s ease, border-color .15s ease, background .15s ease;
}
.input:focus {
  box-shadow: 0 0 0 4px var(--ring);
}

/* cartões */
.card {
  background: var(--card);
  border: 1px solid var(--borderC);
  border-radius: var(--radius-lg);
  box-shadow: var(--elev);
}
CSS
}
apply_tokens

# 1) Layout SSR – escolhe tema pelo cookie (sem flicker) e injeta o chrome
cat > app/layout.tsx <<'TSX'
import "./styles/globals.css";
import "./styles/tokens.css";
import type { Metadata } from "next";
import { cookies } from "next/headers";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const role = (cookies().get("role")?.value as "admin" | "sponsor" | undefined) ?? "admin";
  const brand = cookies().get("brand")?.value;
  const isSponsor = role === "sponsor";
  const themeAttr = isSponsor ? "dark" : "";

  return (
    <html lang="pt-BR" data-theme={themeAttr}>
      <body>
        {/* Topbar tem avatar (→ /settings) e logo do sponsor quando existir */}
        <Topbar role={role} brand={brand} />
        <div className="mx-auto max-w-screen-2xl grid grid-cols-[260px,1fr] gap-6 p-6">
          <Sidebar role={role} />
          <main className="min-h-[70vh]">{children}</main>
        </div>
      </body>
    </html>
  );
}
TSX

# 2) Topbar – avatar/menuzinho + logo do sponsor à direita
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";

type Props = { role?: "admin"|"sponsor"; brand?: string };
type Profile = { name?: string; email?: string; logoUrl?: string };

function useProfile(brand?: string): Profile {
  const [p, setP] = useState<Profile>({});
  useEffect(() => {
    try {
      const raw = localStorage.getItem("companyProfile");
      const saved = raw ? JSON.parse(raw) : {};
      const url = brand ? `/logos/${brand}.png` : undefined;
      setP({ ...saved, logoUrl: url });
    } catch {}
  }, [brand]);
  return p;
}

export default function Topbar({ role, brand }: Props) {
  const profile = useProfile(brand);
  const initials = (profile?.name ?? "Perfil").trim().split(/\s+/).slice(0,2).map(s=>s[0]?.toUpperCase()).join("") || "P";

  return (
    <header className="sticky top-0 z-40 w-full border-b border-border bg-card/90 backdrop-blur">
      <div className="mx-auto max-w-screen-2xl flex items-center justify-between gap-3 px-6 py-3">
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-xl bg-[var(--accent)]" />
          <span className="font-semibold">Engage Dashboard</span>
          {role === "sponsor" && profile.logoUrl && (
            <div className="ml-3 flex items-center gap-2 pl-3 border-l border-border">
              <Image src={profile.logoUrl} alt="logo" width={90} height={28} className="object-contain" />
              <span className="text-muted text-sm">{brand}</span>
            </div>
          )}
        </div>

        <Link href="/settings" className="group flex items-center gap-3">
          <div className="h-9 w-9 rounded-full bg-surface border border-border grid place-items-center shadow-soft">
            <span className="text-[12px] font-semibold">{initials}</span>
          </div>
          <span className="text-sm text-muted group-hover:opacity-80 transition">Settings</span>
        </Link>
      </div>
    </header>
  );
}
TSX

# 3) Sidebar – mantém menus e higieniza estilos (já filtra por role)
cat > components/ui/Sidebar.tsx <<'TSX'
"use client";
import Link from "next/link";

export default function Sidebar({ role = "admin" as "admin" | "sponsor" }) {
  const adminItems = [
    { href: "/", label: "Dashboard" },
    { href: "/pipeline", label: "Pipeline" },
    { href: "/projetos", label: "Projetos" },
    { href: "/admin", label: "Admin" },
  ];
  const sponsorItems = [
    { href: "/sponsor/heineken/overview", label: "Overview" },
    { href: "/sponsor/heineken/results", label: "Resultados" },
    { href: "/sponsor/heineken/financials", label: "Financeiro" },
  ];
  const items = role === "sponsor" ? sponsorItems : adminItems;

  return (
    <aside className="self-start">
      <nav className="card p-3">
        <div className="px-2 pb-2 text-sm text-muted">Navegação</div>
        <ul className="space-y-2">
          {items.map((it) => (
            <li key={it.href}>
              <Link
                href={it.href}
                className="block rounded-xl border border-transparent bg-card hover:border-border px-4 py-3 transition shadow-soft"
              >
                {it.label}
              </Link>
            </li>
          ))}
        </ul>
        <div className="px-2 pt-4 text-sm text-muted">Configurações</div>
        <Link href="/settings" className="mt-2 block rounded-xl px-4 py-3 hover:bg-surface border border-transparent hover:border-border transition">
          Settings
        </Link>
      </nav>
    </aside>
  );
}
TSX

# 4) Botão – mantemos a versão arredondada/brilho
cat > components/ui/Button.tsx <<'TSX'
"use client";
import clsx from "clsx";
type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "solid" | "outline";
  size?: "sm" | "md" | "lg";
};
export default function Button({ variant="solid", size="md", className, ...rest }: Props) {
  const base =
    "inline-flex items-center justify-center rounded-full font-medium transition " +
    "focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-[var(--accent)] " +
    "disabled:opacity-60 disabled:cursor-not-allowed";
  const sizes = { sm:"h-9 px-4 text-sm", md:"h-11 px-5", lg:"h-12 px-6 text-[15px]" } as const;
  const variants = {
    solid: "bg-[var(--accent)] text-white shadow-[0_8px_24px_rgba(16,167,221,.35)] hover:brightness-[1.03] hover:shadow-[0_10px_28px_rgba(16,167,221,.45)] active:brightness-[.98]",
    outline: "border border-current/15 text-[var(--text)] bg-transparent hover:bg-white/50 dark:hover:bg-white/5",
  } as const;
  return <button className={clsx(base, sizes[size], variants[variant], className)} {...rest} />;
}
TSX

# 5) Settings – formulário simples (salvo em localStorage só pra demo)
mkdir -p app/settings
cat > app/settings/page.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";
import Button from "@/components/ui/Button";

type Company = {
  name?: string;
  cnpj?: string;
  email?: string;
  phone?: string;
};

export default function SettingsPage() {
  const [data, setData] = useState<Company>({});

  useEffect(() => {
    try {
      const raw = localStorage.getItem("companyProfile");
      if (raw) setData(JSON.parse(raw));
    } catch {}
  }, []);

  function save() {
    localStorage.setItem("companyProfile", JSON.stringify(data));
    alert("Dados salvos!");
  }

  return (
    <section className="space-y-6">
      <div className="card p-6">
        <h1 className="text-xl font-semibold">Perfil da Empresa</h1>
        <p className="text-sm text-muted mt-1">Edite as informações básicas do patrocinador.</p>
        <div className="mt-6 grid md:grid-cols-2 gap-4">
          <label className="block">
            <div className="text-sm mb-1">Nome fantasia</div>
            <input className="input" value={data.name ?? ""} onChange={e=>setData(d=>({ ...d, name:e.target.value }))} placeholder="Heineken Brasil"/>
          </label>
          <label className="block">
            <div className="text-sm mb-1">CNPJ</div>
            <input className="input" value={data.cnpj ?? ""} onChange={e=>setData(d=>({ ...d, cnpj:e.target.value }))} placeholder="00.000.000/0000-00"/>
          </label>
          <label className="block">
            <div className="text-sm mb-1">E‑mail</div>
            <input className="input" type="email" value={data.email ?? ""} onChange={e=>setData(d=>({ ...d, email:e.target.value }))} placeholder="contato@empresa.com"/>
          </label>
          <label className="block">
            <div className="text-sm mb-1">Telefone</div>
            <input className="input" value={data.phone ?? ""} onChange={e=>setData(d=>({ ...d, phone:e.target.value }))} placeholder="(11) 99999‑9999"/>
          </label>
        </div>
        <div className="mt-6">
          <Button onClick={save} size="lg" className="px-6">Salvar</Button>
        </div>
      </div>
    </section>
  );
}
TSX

# 6) Login – pequenos toques visuais (mantém cookies como já está)
sed -i 's/className="w-full h-12/className="input/g' app/login/login-form.tsx 2>/dev/null || true
sed -i 's/className="w-full h-11/className="input/g' app/login/login-form.tsx 2>/dev/null || true
sed -i 's/bg-card shadow-soft transition/bg-card shadow-soft transition hover:shadow-lg/g' app/login/login-form.tsx

# 7) Middleware – libera /settings para ambos os perfis (autenticados)
perl -0777 -pe 's/(const PUBLIC_PATHS .*?= \[)([^\]]*)(\])/sprintf("%s%s%s",$1,$2, ", \"/settings\"")/se' -i middleware.ts

# 8) Garante logo do sponsor (Heineken)
mkdir -p public/logos
[ -f public/logos/heineken.png ] || [ -f public/logos/heineken.jpg ] || cp heineken.png public/logos/heineken.png 2>/dev/null || true

# 9) Build e commit
pnpm build && git add -A && git commit -m "feat(ui): tema SSR sem flicker, topbar com logo/avatar, settings e estética cards/inputs" && git push