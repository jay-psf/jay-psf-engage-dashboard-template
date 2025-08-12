set -euo pipefail

echo "== Patch 31: Mega Release (UI/UX + fix Topbar regex) =="

# ---------------------------------------------------------
# 1) Sessão: helper central (usa sempre aqui, não reimplementar em Topbar)
# ---------------------------------------------------------
mkdir -p components/lib
cat > components/lib/session.ts <<'TS'
"use client";

export type Role = "admin" | "sponsor";
export type ThemePref = "light" | "dark" | "system";
export type Session = { role?: Role; brand?: string; username?: string };

export function readCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  // Escapa com segurança o nome do cookie
  const escaped = name.replace(/([.$?*|{}()[\]\\/+^])/g, "\\$1");
  const re = new RegExp("(?:^|; )" + escaped + "=([^;]*)");
  const m = document.cookie.match(re);
  return m ? decodeURIComponent(m[1]) : undefined;
}

export function readSession(): Session {
  if (typeof document === "undefined") return {};
  const role = readCookie("role") as Role | undefined;
  const brand = readCookie("brand");
  const username = readCookie("username") || undefined;
  return { role, brand, username };
}

export function setThemeAttr(theme: ThemePref, role?: Role) {
  const el = document.documentElement;
  let mode: "light"|"dark";
  if (theme === "system") {
    const mq = window.matchMedia("(prefers-color-scheme: dark)");
    mode = mq.matches ? "dark" : "light";
  } else {
    mode = theme;
  }
  // regra: sponsor preferencialmente dark, mas respeita settings se for explicitamente "light"
  if (role === "sponsor" && theme !== "light") mode = "dark";
  el.setAttribute("data-theme", mode);
}

export function getThemePref(): ThemePref {
  if (typeof window === "undefined") return "system";
  return (localStorage.getItem("themePref") as ThemePref) || "system";
}

export function saveThemePref(pref: ThemePref) {
  if (typeof window === "undefined") return;
  localStorage.setItem("themePref", pref);
}

export function clearSessionAndGoLogin() {
  try {
    if (typeof document !== "undefined") {
      // limpa cookies simples (role/brand/username)
      document.cookie = "role=; Max-Age=0; path=/";
      document.cookie = "brand=; Max-Age=0; path=/";
      document.cookie = "username=; Max-Age=0; path=/";
    }
    if (typeof window !== "undefined") {
      localStorage.clear();
      sessionStorage.clear();
    }
  } finally {
    if (typeof window !== "undefined") window.location.href = "/login";
  }
}
TS

# ---------------------------------------------------------
# 2) Tokens e efeitos (glow/iris refinado + dark 100% escuro sponsor)
# ---------------------------------------------------------
cat > styles/tokens.css <<'CSS'
:root{
  /* Brand / Accent (roxo) */
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;

  /* Light */
  --bg:#F6F8FB; --card:#FFFFFF; --surface:#F2F4F9;
  --text:#0B1524; --muted:#667085; --borderC:rgba(16,24,40,.12);

  /* Dark */
  --bg-dark:#0B1220; --card-dark:#0A1020; --surface-dark:#090E1A;
  --text-dark:#E6E8EC; --muted-dark:#9BA3AF; --borderC-dark:rgba(255,255,255,.10);

  /* Sombras/halos */
  --elev:0 10px 30px rgba(2,32,71,.08);
  --elev-strong:0 18px 50px rgba(2,32,71,.15);
  --elev-dark:0 14px 36px rgba(0,0,0,.35);

  /* Iris/Glow refinado */
  --ring:rgba(126,58,242,.35);
  --ring-strong:rgba(126,58,242,.60);
  --halo:0 0 0 8px var(--ring);
  --halo-strong:0 0 0 12px var(--ring-strong);

  /* Radius */
  --radius:16px; --radius-lg:22px;
}

:root[data-theme="dark"]{
  --bg:var(--bg-dark); --card:var(--card-dark); --surface:var(--surface-dark);
  --text:var(--text-dark); --muted:var(--muted-dark); --borderC:var(--borderC-dark);
}

/* Base com gradiente sutil fixo */
html,body{
  background: var(--bg);
  color: var(--text);
  min-height:100%;
  background-image:
    radial-gradient(1200px 600px at 10% -20%, rgba(126,58,242,.06), transparent 45%),
    radial-gradient(900px 500px at 90% -10%, rgba(126,58,242,.04), transparent 50%);
  background-attachment: fixed;
}

/* Helpers */
.bg-card{background:var(--card);}
.bg-surface{background:var(--surface);}
.text-muted{color:var(--muted);}
.border{border:1px solid var(--borderC);}
.border-border{border-color:var(--borderC);}
.rounded-xl{border-radius:var(--radius);}
.rounded-2xl{border-radius:var(--radius-lg);}
.shadow-soft{box-shadow:var(--elev);}

/* Glow utilitário (sutil porém impactante) */
.glow-iris{ box-shadow: 0 0 0 0 rgba(0,0,0,0), 0 0 24px rgba(126,58,242,.18); }
.glow-iris:hover{ box-shadow: 0 0 0 0 rgba(0,0,0,0), 0 0 42px rgba(126,58,242,.28); }

/* Lift on hover/press */
.hover-lift{ transition: transform .18s ease, box-shadow .18s ease; }
.hover-lift:hover{ transform: translateY(-2px); }
.pressable:active{ transform: translateY(0); }

/* Inputs simples */
.input{height:48px;width:100%;border:1px solid var(--borderC);background:var(--surface);border-radius:14px;padding:0 12px;color:var(--text);}

/* Pills de navegação topo */
.pill{border-radius:999px;padding:.5rem .9rem;border:1px solid var(--borderC);background:transparent;color:var(--text);display:inline-flex;gap:.5rem;align-items:center;transition:background .18s ease, color .18s ease, box-shadow .18s ease;}
.pill:hover{background:var(--surface);}
.pill.active{background:var(--accent);color:white;border-color:transparent;box-shadow:0 8px 20px rgba(126,58,242,.35);}
CSS

# ---------------------------------------------------------
# 3) Botão com variantes + glow/iris refinado
# ---------------------------------------------------------
mkdir -p components/ui
cat > components/ui/Button.tsx <<'TSX'
"use client";
import { cn } from "@/lib/cn";
import React from "react";

type Variant = "primary" | "outline" | "ghost";
type Size = "sm" | "md" | "lg";

const base = "inline-flex items-center justify-center font-medium rounded-2xl hover-lift pressable focus-visible:outline-none";
const sizes: Record<Size,string> = {
  sm: "h-9 px-3 text-sm",
  md: "h-11 px-4 text-sm",
  lg: "h-12 px-6 text-base",
};
const variants: Record<Variant,string> = {
  primary: "bg-[var(--accent)] text-white shadow-soft glow-iris hover:shadow-[var(--elev-strong)]",
  outline: "border border-border bg-transparent text-[var(--text)] hover:bg-[var(--surface)]",
  ghost: "text-[var(--text)] hover:bg-[var(--surface)]",
};

export default function Button(
  { className, variant="primary", size="md", ...rest }:
  React.ButtonHTMLAttributes<HTMLButtonElement> & { variant?: Variant; size?: Size }
){
  return <button className={cn(base, sizes[size], variants[variant], className)} {...rest} />;
}
TSX

# ---------------------------------------------------------
# 4) Skeleton simples com shimmer
# ---------------------------------------------------------
cat > components/ui/Skeleton.tsx <<'TSX'
"use client";
import React from "react";
export default function Skeleton({ className }: { className?: string }){
  return (
    <div className={["animate-pulse bg-[color-mix(in_oklab,white_8%,transparent)] dark:bg-[rgba(255,255,255,.06)] rounded-xl", className].join(" ")} />
  );
}
TSX

# ---------------------------------------------------------
# 5) MetricCard padronizado
# ---------------------------------------------------------
cat > components/ui/MetricCard.tsx <<'TSX'
"use client";
import React from "react";

export default function MetricCard(
  { title, value, footer }: { title: string; value: string; footer?: string }
){
  return (
    <div className="bg-card border border-border rounded-2xl p-4 shadow-soft hover-lift">
      <div className="text-sm text-muted">{title}</div>
      <div className="mt-2 text-2xl font-semibold">{value}</div>
      {footer && <div className="text-xs text-muted mt-3">{footer}</div>}
    </div>
  );
}
TSX

# ---------------------------------------------------------
# 6) Topbar unificada (corrige regex: remove leitura local e usa helper)
#    - Sponsor: logo maior (sem texto), menu superior único
#    - Logout robusto
# ---------------------------------------------------------
cat > components/ui/Topbar.tsx <<'TSX'
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
TSX

# ---------------------------------------------------------
# 7) ClientShell: aplica tema por preferência (light/dark/system) e por papel
#    esconde chrome em /login
# ---------------------------------------------------------
cat > components/ClientShell.tsx <<'TSX'
"use client";
import { useEffect } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import { getThemePref, setThemeAttr, readSession } from "@/components/lib/session";

export default function ClientShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";
  const { role } = readSession();

  useEffect(() => {
    const pref = getThemePref();
    setThemeAttr(pref, role);
  }, [role]);

  if (isLogin) return <>{children}</>;
  return (
    <>
      <Topbar />
      <div className="mx-auto max-w-screen-2xl p-6">
        {children}
      </div>
    </>
  );
}
TSX

# ---------------------------------------------------------
# 8) Login: toggle deslizante (Admin / Sponsor) + layout centralizado
# ---------------------------------------------------------
cat > app/login/login-form.tsx <<'TSX'
"use client";
import { useState, useEffect } from "react";
import Button from "@/components/ui/Button";

type Role = "admin" | "sponsor";

export default function LoginForm(){
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(()=>{ setUsername("admin"); setPassword("123456"); }, []);

  function resolveBrandFromUser(u: string){ return u.toLowerCase() === "sponsor" ? "heineken" : "acme"; }

  async function onSubmit(e: React.FormEvent){
    e.preventDefault();
    const ok = (role==="admin" && username==="admin" && password==="123456")
            || (role==="sponsor" && username==="sponsor" && password==="000000");
    if(!ok) return alert("Usuário ou senha inválidos");
    setLoading(true);
    const brand = role==="sponsor" ? resolveBrandFromUser(username) : undefined;
    const resp = await fetch("/api/auth", { method:"POST", headers:{ "content-type":"application/json" }, body: JSON.stringify({ role, brand }) });
    setLoading(false);
    if(!resp.ok) return alert("Falha ao autenticar");
    window.location.href = role==="sponsor" ? `/sponsor/${brand}/overview` : "/";
  }

  return (
    <div className="min-h-[calc(100vh-64px)] grid place-items-center px-4">
      <div className="w-full max-w-md bg-card border border-border rounded-2xl p-6 shadow-soft">
        <div className="text-center text-xl font-semibold">Entrar</div>

        {/* Toggle deslizante */}
        <div className="mt-4 relative bg-surface border border-border rounded-2xl p-1 grid grid-cols-2">
          <div
            className="absolute top-1 bottom-1 w-1/2 rounded-xl bg-[var(--accent)] transition-transform"
            style={{ transform: role==="admin" ? "translateX(0%)" : "translateX(100%)" }}
          />
          <button type="button" onClick={()=>{ setRole("admin"); setUsername("admin"); setPassword("123456"); }}
            className={["relative z-10 h-10 rounded-xl", role==="admin" ? "text-white" : "text-[var(--text)]"].join(" ")}
          >Admin</button>
          <button type="button" onClick={()=>{ setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}
            className={["relative z-10 h-10 rounded-xl", role==="sponsor" ? "text-white" : "text-[var(--text)]"].join(" ")}
          >Patrocinador</button>
        </div>

        <form onSubmit={onSubmit} className="mt-5 space-y-3">
          <label className="block">
            <div className="text-sm mb-1">Usuário</div>
            <input value={username} onChange={(e)=>setUsername(e.target.value)} className="input" placeholder={role==="admin"?"admin":"sponsor"} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">Senha</div>
            <input value={password} onChange={(e)=>setPassword(e.target.value)} className="input" type="password" placeholder={role==="admin"?"123456":"000000"} />
          </label>

          <div className="pt-2 flex gap-2">
            <Button type="submit" size="lg">{loading ? "Entrando..." : "Entrar"}</Button>
            <Button type="button" variant="outline" onClick={()=>{
              if(role==="admin"){ setUsername("admin"); setPassword("123456"); }
              else { setUsername("sponsor"); setPassword("000000"); }
            }}>Preencher exemplo</Button>
          </div>
        </form>
      </div>
    </div>
  );
}
TSX

# ---------------------------------------------------------
# 9) Settings Sponsor (garante rota e selector de tema)
# ---------------------------------------------------------
mkdir -p app/sponsor/[brand]/settings
cat > app/sponsor/[brand]/settings/page.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";
import { saveThemePref, getThemePref, setThemeAttr, readSession } from "@/components/lib/session";
import Button from "@/components/ui/Button";

export default function SponsorSettingsPage(){
  const { role } = readSession();
  const [pref, setPref] = useState<"light"|"dark"|"system">("system");

  useEffect(()=>{ setPref(getThemePref()); },[]);
  useEffect(()=>{ setThemeAttr(pref, role); saveThemePref(pref); },[pref, role]);

  return (
    <div className="space-y-6">
      <h1 className="text-xl font-semibold">Configurações do Patrocinador</h1>

      <section className="bg-card border border-border rounded-2xl p-4">
        <div className="font-medium mb-2">Tema</div>
        <div className="flex gap-2">
          <Button variant={pref==="light"?"primary":"outline"} onClick={()=>setPref("light")}>Light</Button>
          <Button variant={pref==="dark"?"primary":"outline"} onClick={()=>setPref("dark")}>Dark</Button>
          <Button variant={pref==="system"?"primary":"outline"} onClick={()=>setPref("system")}>Sistema</Button>
        </div>
      </section>

      <section className="bg-card border border-border rounded-2xl p-4">
        <div className="font-medium mb-2">Informações da Conta</div>
        <div className="grid sm:grid-cols-2 gap-3">
          <input className="input" placeholder="Razão social" />
          <input className="input" placeholder="CNPJ" />
          <input className="input" placeholder="E-mail" />
          <input className="input" placeholder="Telefone" />
        </div>
      </section>
    </div>
  );
}
TSX

# ---------------------------------------------------------
# 10) (Opcional) Settings Admin garante seletor de tema
# ---------------------------------------------------------
mkdir -p app/settings
cat > app/settings/page.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";
import { saveThemePref, getThemePref, setThemeAttr, readSession } from "@/components/lib/session";
import Button from "@/components/ui/Button";

export default function AdminSettingsPage(){
  const { role } = readSession();
  const [pref, setPref] = useState<"light"|"dark"|"system">("system");

  useEffect(()=>{ setPref(getThemePref()); },[]);
  useEffect(()=>{ setThemeAttr(pref, role); saveThemePref(pref); },[pref, role]);

  return (
    <div className="space-y-6">
      <h1 className="text-xl font-semibold">Configurações</h1>
      <section className="bg-card border border-border rounded-2xl p-4">
        <div className="font-medium mb-2">Tema</div>
        <div className="flex gap-2">
          <Button variant={pref==="light"?"primary":"outline"} onClick={()=>setPref("light")}>Light</Button>
          <Button variant={pref==="dark"?"primary":"outline"} onClick={()=>setPref("dark")}>Dark</Button>
          <Button variant={pref==="system"?"primary":"outline"} onClick={()=>setPref("system")}>Sistema</Button>
        </div>
      </section>
    </div>
  );
}
TSX

# ---------------------------------------------------------
# 11) Build
# ---------------------------------------------------------
echo "== Build =="
pnpm build
