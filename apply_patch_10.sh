set -euo pipefail

echo "== Patch 10: Logo pill + Sponsor Settings + contrast polish =="

# 1) Topbar com pílula de marca (só logo) usando next/image
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";
import Button from "@/components/ui/Button";
import { readSession } from "@/components/lib/session";

export default function Topbar() {
  const [{ role, brand }, setSes] = useState<{role?: "admin"|"sponsor", brand?: string}>({});
  useEffect(()=>{ setSes(readSession() ?? {}); },[]);

  async function logout() {
    try { await fetch("/api/logout", { method: "POST" }); } finally { window.location.href = "/login"; }
  }

  return (
    <header className="sticky top-0 z-30 border-b border-[var(--borderC)] bg-[var(--bg)]/85 backdrop-blur">
      <div className="mx-auto flex max-w-screen-2xl items-center justify-between gap-3 px-4 py-3">
        <Link href={role === "sponsor" ? `/sponsor/${brand}/overview` : "/"} className="flex items-center gap-2">
          <div className="grid h-8 w-8 place-items-center rounded-full bg-[var(--accent)] text-white font-semibold">E</div>
          <span className="text-sm font-medium opacity-90">Engage</span>
        </Link>

        <div className="flex items-center gap-3">
          {role === "sponsor" && brand && (
            <Link
              href={`/sponsor/${brand}/settings`}
              className="group inline-flex items-center rounded-full border border-[var(--borderC)] bg-[var(--surface)]/40 px-2.5 py-1.5 transition hover:bg-[var(--surface)]/70 focus:outline-none focus:ring-4 focus:ring-[var(--ring)]"
              aria-label={`${brand} settings`}
            >
              <Image
                src={`/logos/${brand}.png`}
                alt={brand}
                width={22}
                height={22}
                className="rounded-md block md:w-[24px] md:h-[24px]"
              />
            </Link>
          )}
          <Button variant="outline" size="md" onClick={logout}>Sair</Button>
        </div>
      </div>
    </header>
  );
}
TSX

# 2) Sidebar: hover/ativo + link correto pra settings do sponsor
cat > components/ui/Sidebar.tsx <<'TSX'
"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { readSession } from "@/components/lib/session";

const itemCls = (active:boolean)=>[
  "block rounded-[24px] border px-4 py-3 transition shadow-soft",
  "border-[var(--borderC)] bg-[var(--surface)]/30 hover:bg-[var(--surface)]/60",
  active ? "ring-4 ring-[var(--ring)]" : ""
].join(" ");

export default function Sidebar() {
  const pathname = usePathname();
  const [{ role, brand }, setSes] = useState<{role?: "admin"|"sponsor", brand?: string}>({});
  useEffect(()=>{ setSes(readSession() ?? {}); },[]);

  if (role === "sponsor" && brand) {
    const base = `/sponsor/${brand}`;
    const links = [
      { href: `${base}/overview`,   label: "Overview" },
      { href: `${base}/results`,    label: "Resultados" },
      { href: `${base}/financials`, label: "Financeiro" },
      { href: `${base}/events`,     label: "Eventos" },
      { href: `${base}/assets`,     label: "Assets" },
      { href: `${base}/settings`,   label: "Settings" },
    ];
    return (
      <aside className="space-y-3">
        {links.map(l=>(
          <Link key={l.href} href={l.href} className={itemCls(pathname === l.href)}>{l.label}</Link>
        ))}
      </aside>
    );
  }

  const links = [
    { href: "/",           label: "Overview" },
    { href: "/projetos",   label: "Resultados" },
    { href: "/financials", label: "Financeiro" },
    { href: "/pipeline",   label: "Pipeline" },
    { href: "/settings",   label: "Settings" },
  ];
  return (
    <aside className="space-y-3">
      {links.map(l=>(
        <Link key={l.href} href={l.href} className={itemCls(pathname === l.href)}>{l.label}</Link>
      ))}
    </aside>
  );
}
TSX

# 3) Settings do patrocinador: tema + perfil (CNPJ/telefone com máscara, persistência local)
mkdir -p app/sponsor/[brand]/settings
cat > app/sponsor/[brand]/settings/page.tsx <<'TSX'
"use client";
import { useEffect, useMemo, useState } from "react";
import Button from "@/components/ui/Button";

type ThemePref = "light" | "dark" | "system";

function formatCNPJ(v:string){
  const d = v.replace(/\D/g,"").slice(0,14);
  return d
    .replace(/^(\d{2})(\d)/, "$1.$2")
    .replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3")
    .replace(/\.(\d{3})(\d)/, ".$1/$2")
    .replace(/(\d{4})(\d)/, "$1-$2");
}
function formatPhone(v:string){
  const d = v.replace(/\D/g,"").slice(0,11);
  if (d.length <= 10) {
    return d.replace(/^(\d{0,2})(\d{0,4})(\d{0,4}).*/, (_,a,b,c)=>[
      a?`(${a}`:"", a&&a.length===2?") ":"", b, b&&c?"-":"", c
    ].join(""));
  }
  return d.replace(/^(\d{2})(\d{5})(\d{4}).*/, "($1) $2-$3");
}

export default function SponsorSettingsPage({ params }: { params: { brand: string } }) {
  const brand = params.brand;
  const storageKey = useMemo(()=>`sponsorProfile-${brand}`,[brand]);

  const [pref, setPref] = useState<ThemePref>("system");
  const [company, setCompany] = useState("");
  const [cnpj, setCNPJ] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [contact, setContact] = useState("");

  // carrega preferências/dados
  useEffect(()=>{
    const p = window.localStorage.getItem("themePref") as ThemePref | null;
    if (p) setPref(p);
    const raw = window.localStorage.getItem(storageKey);
    if (raw) {
      try {
        const s = JSON.parse(raw);
        setCompany(s.company ?? "");
        setCNPJ(s.cnpj ?? "");
        setEmail(s.email ?? "");
        setPhone(s.phone ?? "");
        setContact(s.contact ?? "");
      } catch {}
    }
  },[storageKey]);

  // aplica tema
  useEffect(()=>{
    if (pref === "system") {
      window.localStorage.setItem("themePref","system");
      const mq = window.matchMedia("(prefers-color-scheme: dark)");
      document.documentElement.setAttribute("data-theme", mq.matches ? "dark" : "light");
      const l = (e:MediaQueryListEvent)=>document.documentElement.setAttribute("data-theme", e.matches?"dark":"light");
      mq.addEventListener?.("change", l);
      return ()=>mq.removeEventListener?.("change", l);
    } else {
      window.localStorage.setItem("themePref",pref);
      document.documentElement.setAttribute("data-theme", pref);
    }
  },[pref]);

  function save() {
    const payload = { company, cnpj, email, phone, contact };
    window.localStorage.setItem(storageKey, JSON.stringify(payload));
    alert("Informações salvas!");
  }

  return (
    <main className="space-y-6">
      <section className="rounded-2xl border border-[var(--borderC)] bg-[var(--card)] p-5 shadow-soft">
        <h2 className="text-base font-semibold mb-3">Tema</h2>
        <div className="grid gap-3 sm:grid-cols-3">
          {(["light","dark","system"] as ThemePref[]).map(t=>(
            <button
              key={t}
              onClick={()=>setPref(t)}
              className={[
                "rounded-2xl border p-4 text-left transition",
                "border-[var(--borderC)] bg-[var(--surface)]/40 hover:bg-[var(--surface)]/70",
                pref===t ? "ring-4 ring-[var(--ring)]" : ""
              ].join(" ")}
            >
              <div className="text-sm text-[var(--muted)]">Preferência</div>
              <div className="mt-1 font-medium capitalize">{t}</div>
            </button>
          ))}
        </div>
      </section>

      <section className="rounded-2xl border border-[var(--borderC)] bg-[var(--card)] p-5 shadow-soft">
        <h2 className="text-base font-semibold mb-4">Informações da Empresa</h2>
        <div className="grid gap-4 md:grid-cols-2">
          <label className="block">
            <div className="mb-1 text-sm">Razão Social</div>
            <input className="input" value={company} onChange={(e)=>setCompany(e.target.value)} placeholder="Heineken Brasil" />
          </label>
          <label className="block">
            <div className="mb-1 text-sm">CNPJ</div>
            <input className="input" value={cnpj} onChange={(e)=>setCNPJ(formatCNPJ(e.target.value))} placeholder="00.000.000/0000-00" />
          </label>
          <label className="block">
            <div className="mb-1 text-sm">E-mail</div>
            <input className="input" value={email} onChange={(e)=>setEmail(e.target.value)} placeholder="contato@empresa.com.br" />
          </label>
          <label className="block">
            <div className="mb-1 text-sm">Telefone</div>
            <input className="input" value={phone} onChange={(e)=>setPhone(formatPhone(e.target.value))} placeholder="(11) 90000-0000" />
          </label>
          <label className="block md:col-span-2">
            <div className="mb-1 text-sm">Responsável</div>
            <input className="input" value={contact} onChange={(e)=>setContact(e.target.value)} placeholder="Nome do contato" />
          </label>
        </div>

        <div className="mt-5">
          <Button size="lg" onClick={save}>Salvar</Button>
        </div>
      </section>
    </main>
  );
}
TSX

# 4) Botão com contraste/hover/focus melhores
cat > components/ui/Button.tsx <<'TSX'
"use client";
import { ButtonHTMLAttributes } from "react";
import clsx from "clsx";

type Props = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "outline";
  size?: "md" | "lg";
};
export default function Button({ className, variant="primary", size="md", ...rest }: Props) {
  const base = "inline-flex items-center justify-center rounded-2xl font-medium transition focus:outline-none focus-visible:ring-4 focus-visible:ring-[var(--ring)]";
  const sizes = size==="lg" ? "h-11 px-6 text-sm" : "h-10 px-4 text-sm";
  const styles = variant==="primary"
    ? "bg-[var(--accent)] text-white hover:bg-[var(--accent-600)] active:bg-[var(--accent-700)] shadow-soft"
    : "border border-[var(--borderC)] bg-[var(--surface)]/30 text-[var(--text)] hover:bg-[var(--surface)]/60";
  return <button className={clsx(base, sizes, styles, className)} {...rest} />;
}
TSX

# 5) Tokens: apenas ajuste sutil de hover/contrast (mantém dark 100% escuro)
cat > styles/tokens.css <<'CSS'
:root {
  --accent: #7E3AF2;
  --accent-600: #6C2BD9;
  --accent-700: #5B21B6;

  --bg: #F6F8FB;
  --card: #FFFFFF;
  --surface: #F2F4F9;

  --text: #0B1524;
  --muted: #667085;
  --borderC: rgba(16,24,40,0.12);
  --ring: rgba(126,58,242,.35);

  --radius: 16px;
  --radius-lg: 22px;
  --elev: 0 12px 28px rgba(2,32,71,.08);
}

:root[data-theme="dark"] {
  --accent: #9F67FF;
  --accent-600: #8C56F0;
  --accent-700: #7B45DE;

  --bg: #0B0F17;        /* fundo */
  --card: #0F1520;      /* cartões 100% escuros */
  --surface: #0D131D;   /* superfícies 100% escuras */

  --text: #E6E8EC;
  --muted: #9BA3AF;
  --borderC: rgba(255,255,255,0.08);
  --ring: rgba(159,103,255,.45);

  --elev: 0 16px 36px rgba(0,0,0,.45);
}

html, body { background: var(--bg); color: var(--text); }

/* Helpers */
.bg-card { background: var(--card); }
.bg-surface { background: var(--surface); }
.text-muted { color: var(--muted); }
.border { border: 1px solid var(--borderC); }
.border-border { border-color: var(--borderC); }
.rounded-xl { border-radius: var(--radius); }
.rounded-2xl { border-radius: var(--radius-lg); }
.shadow-soft { box-shadow: var(--elev); }

/* Input padrão */
.input {
  height: 44px; width: 100%;
  padding: 0 12px; border-radius: 12px;
  border: 1px solid var(--borderC);
  background: var(--surface);
  outline: none;
}
.input:focus { box-shadow: 0 0 0 4px var(--ring); }
CSS

echo "== Build =="
pnpm build
