#!/usr/bin/env bash
set -euo pipefail

echo "== Patch 2: tipografia, espaçamento e contraste =="

# 0) Sanidade
[ -f package.json ] || { echo "❌ Rode no diretório do projeto (package.json não encontrado)."; exit 2; }

# 1) tokens de design refinados
cat > styles/tokens.css <<'CSS'
:root{
  /* Cores (claro) inspiradas na Entourage */
  --accent:#00A7DD;
  --bg:#F6F8FB;
  --card:#FFFFFF;
  --surface: #FAFBFF;
  --text:#0B1524;
  --muted:#667085;
  --border-color:rgba(16,24,40,0.10);

  /* Tipografia e raios */
  --font-sans: "Inter", system-ui, -apple-system, Segoe UI, Roboto, Arial, "Noto Sans", "Apple Color Emoji","Segoe UI Emoji";
  --font-display: "Sora", var(--font-sans);
  --radius-lg: 14px;
  --radius-xl: 18px;

  /* Efeitos */
  --ring: #00A7DD33;
  --ring-strong: #00A7DD66;
}

:root[data-theme="dark"]{
  --accent:#00A7DD;
  --bg:#0B1220;
  --card:#111827;
  --surface:#0E1524;
  --text:#E6E8EC;
  --muted:#9BA3AF;
  --border-color:rgba(255,255,255,0.12);
  --ring:#00A7DD55;
  --ring-strong:#00A7DD88;
}

html,body{ background:var(--bg); color:var(--text); }
.text-muted{ color:var(--muted); }
.bg-card{ background:var(--card); }
.bg-surface{ background:var(--surface); }
.border{ border:1px solid var(--border-color); }
.shadow-soft{ box-shadow:0 8px 30px rgba(2,32,71,.08); }

/* Utilitários de layout/anim */
.container-main{ width:100%; max-width:1280px; margin:0 auto; padding:1.25rem; }
@media (min-width: 768px){ .container-main{ padding:1.5rem; } }
@keyframes fadeInUp { from{opacity:.01; transform:translateY(6px)} to{opacity:1; transform:none} }
.fade-in { animation: fadeInUp .28s ease-out both; }
CSS

# 2) globals: fontes e utilitários
cat > styles/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Google Fonts (Inter / Sora) */
@import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Sora:wght@600;700&display=swap");
@import "./tokens.css";

:root, :root[data-theme="dark"] { color-scheme: light dark; }

html, body { font-family: var(--font-sans); }
.h-display { font-family: var(--font-display); letter-spacing: -0.01em; }

/* Inputs e cards padrão */
.input {
  width:100%; height:44px; border:1px solid var(--border-color);
  background: color-mix(in oklab, var(--card) 85%, transparent);
  border-radius: var(--radius-lg); padding: 0 .75rem;
  transition: box-shadow .15s ease, border-color .15s ease, background .15s ease;
}
.input::placeholder { color: color-mix(in oklab, var(--text) 45%, transparent); }
.input:focus { outline: none; box-shadow: 0 0 0 3px var(--ring); border-color: var(--accent); background: var(--card); }

.card {
  border: 1px solid var(--border-color);
  background: var(--card);
  border-radius: var(--radius-xl);
  box-shadow: 0 8px 30px rgba(2,32,71,.06);
}

/* botões : já temos componente, mas ajudamos variantes simples em CSS (fallback) */
.btn {
  display:inline-flex; align-items:center; justify-content:center;
  height:44px; padding:0 1rem; border-radius: var(--radius-lg);
  font-weight:600; transition: opacity .2s ease, box-shadow .2s ease, transform .04s ease;
  border:1px solid var(--border-color);
}
.btn:active { transform: translateY(1px); }
.btn-primary{ background: var(--accent); color:#fff; border-color: transparent; }
.btn-outline{ background: var(--card); color: var(--text); }
.btn:hover{ opacity:.95; }
.btn:focus-visible{ outline:none; box-shadow:0 0 0 3px var(--ring-strong); }
CSS

# 3) Button: reforço visual
cat > components/ui/Button.tsx <<'TSX'
"use client";
import React from "react";
import clsx from "clsx";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary"|"outline"|"ghost";
  size?: "sm"|"md"|"lg";
};

export default function Button({variant="primary", size="md", className, disabled, ...rest}:Props){
  const base = "inline-flex items-center justify-center rounded-[14px] font-semibold transition border";
  const byVariant = {
    primary: "bg-[var(--accent)] text-white border-transparent hover:opacity-95 focus-visible:shadow-[0_0_0_3px_var(--ring-strong)]",
    outline: "bg-[var(--card)] text-[var(--text)] hover:shadow-soft focus-visible:shadow-[0_0_0_3px_var(--ring-strong)]",
    ghost: "text-[var(--text)] hover:bg-white/10 focus-visible:shadow-[0_0_0_3px_var(--ring-strong)]"
  }[variant];
  const bySize = { sm:"h-9 px-3 text-sm", md:"h-11 px-4", lg:"h-12 px-6 text-base" }[size];
  const state = disabled ? "opacity-60 cursor-not-allowed" : "";
  return <button className={clsx(base, byVariant, bySize, state, className)} disabled={disabled} {...rest} />;
}
TSX

# 4) Topbar: melhor contraste e alinhamento
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import Link from "next/link";
import Button from "./Button";
import { useEffect, useState } from "react";

type Session = { role?: "admin"|"sponsor"; brand?: string; username?: string };
function readSession(): Session { try { const r=localStorage.getItem("session"); return r? JSON.parse(r):{}; } catch { return {}; } }

export default function Topbar(){
  const [s,setS] = useState<Session>({});
  useEffect(()=>{ setS(readSession()); },[]);
  const isSponsor = s.role==="sponsor";
  const brand = s.brand || "heineken";
  return (
    <header className="sticky top-0 z-30 border bg-card/90 backdrop-blur supports-[backdrop-filter]:bg-card/80">
      <div className="container-main h-16 flex items-center justify-between">
        <div className="flex items-center gap-3">
          {isSponsor ? (
            <Image src={`/logos/${brand}.png`} alt={`${brand} logo`} width={120} height={28} className="object-contain" priority />
          ) : (
            <Link href="/" className="h-display text-lg">Entourage • Engage</Link>
          )}
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" onClick={()=>{
            localStorage.removeItem("session");
            document.documentElement.removeAttribute("data-theme");
            window.location.href="/login";
          }}>Sair</Button>
        </div>
      </div>
    </header>
  );
}
TSX

# 5) Sidebar: estados e foco mais claros
cat > components/ui/Sidebar.tsx <<'TSX'
"use client";
import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { usePathname } from "next/navigation";

type Session = { role?: "admin"|"sponsor"; brand?: string };
function readSession(): Session { try { const r=localStorage.getItem("session"); return r? JSON.parse(r):{}; } catch { return {}; } }

function NavItem({href, label}:{href:string; label:string}){
  const pathname = usePathname();
  const active = useMemo(()=> pathname===href || pathname.startsWith(href + "/"), [pathname, href]);
  return (
    <Link
      href={href}
      className={`rounded-[14px] border bg-card px-4 py-3 hover:shadow-soft transition block ${active? "ring-[3px] ring-[var(--ring)] border-transparent" : ""}`}
      aria-current={active ? "page" : undefined}
    >
      {label}
    </Link>
  );
}

export default function Sidebar(){
  const [s,setS]=useState<Session>({});
  useEffect(()=>{ setS(readSession()); },[]);
  const isSponsor = s.role==="sponsor";
  const brand = s.brand || "heineken";
  return (
    <aside className="hidden md:block w-[260px]">
      <div className="grid gap-2">
        {isSponsor ? (
          <>
            <NavItem href={`/sponsor/${brand}/overview`} label="Visão Geral" />
            <NavItem href={`/sponsor/${brand}/events`}   label="Eventos" />
            <NavItem href={`/sponsor/${brand}/results`}  label="Resultados" />
            <NavItem href={`/sponsor/${brand}/financials`} label="Financeiro" />
            <NavItem href={`/sponsor/${brand}/assets`}   label="Assets" />
          </>
        ) : (
          <>
            <NavItem href="/"          label="Dashboard" />
            <NavItem href="/pipeline"  label="Pipeline" />
            <NavItem href="/projetos"  label="Projetos" />
            <NavItem href="/admin"     label="Admin" />
          </>
        )}
      </div>
    </aside>
  );
}
TSX

# 6) Login form: inputs e hierarquia visual
cat > app/login/login-form.tsx <<'TSX'
"use client";
import { useState, useEffect } from "react";
import Button from "@/components/ui/Button";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  useEffect(()=>{ setUsername("admin"); setPassword("123456"); },[]);

  async function onSubmit(e: React.FormEvent){
    e.preventDefault();
    const ok = (role==="admin" && username==="admin" && password==="123456")
            || (role==="sponsor" && username==="sponsor" && password==="000000");
    if(!ok){ alert("Usuário ou senha inválidos"); return; }

    const session = { role, username, brand: role==="sponsor" ? "heineken" : undefined };
    localStorage.setItem("session", JSON.stringify(session));

    if (role==="sponsor"){
      document.documentElement.setAttribute("data-theme","dark");
      window.location.href = `/sponsor/${session.brand}/overview`;
    } else {
      document.documentElement.removeAttribute("data-theme");
      window.location.href = "/";
    }
  }

  return (
    <div className="w-full max-w-4xl mx-auto space-y-6 fade-in">
      <div className="grid md:grid-cols-2 gap-4">
        <button onClick={()=>setRole("admin")}
          className={`text-left rounded-[18px] border px-5 py-4 bg-card hover:shadow-soft transition ${role==="admin"?"ring-[3px] ring-[var(--ring)] border-transparent":""}`}>
          <div className="text-xs uppercase tracking-wide text-muted">Perfil</div>
          <div className="mt-1 h-display text-xl">Interno (Admin)</div>
          <div className="text-sm text-muted mt-1">Acesso completo</div>
        </button>

        <button onClick={()=>setRole("sponsor")}
          className={`text-left rounded-[18px] border px-5 py-4 bg-card hover:shadow-soft transition ${role==="sponsor"?"ring-[3px] ring-[var(--ring)] border-transparent":""}`}>
          <div className="text-xs uppercase tracking-wide text-muted">Perfil</div>
          <div className="mt-1 h-display text-xl">Patrocinador</div>
          <div className="text-sm text-muted mt-1">Acompanha seu contrato</div>
        </button>
      </div>

      <form onSubmit={onSubmit} className="card p-6 space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <label className="block">
            <div className="text-sm mb-1">Usuário</div>
            <input value={username} onChange={(e)=>setUsername(e.target.value)}
              className="input" placeholder={role==="admin"?"admin":"sponsor"} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">Senha</div>
            <input value={password} onChange={(e)=>setPassword(e.target.value)}
              className="input" placeholder={role==="admin"?"123456":"000000"} type="password" />
          </label>
        </div>

        <div className="flex gap-3 pt-2">
          <Button type="submit" size="lg" className="px-6">Entrar</Button>
          <Button type="button" variant="outline" onClick={()=>{
            if(role==="admin"){ setUsername("admin"); setPassword("123456"); }
            else { setUsername("sponsor"); setPassword("000000"); }
          }}>Preencher exemplo</Button>
        </div>
      </form>
    </div>
  );
}
TSX

# 7) Página /login (usa form)
cat > app/login/page.tsx <<'TSX'
import type { Metadata } from "next";
import LoginForm from "./login-form";

export const metadata: Metadata = { title: "Login • Engage" };

export default function Page(){
  return (
    <main className="w-full px-4 min-h-[calc(100vh-64px)] grid place-items-center">
      <div className="w-full max-w-5xl">
        <h1 className="sr-only">Entrar</h1>
        <LoginForm />
      </div>
    </main>
  );
}
TSX

# 8) Garantir dependência
pnpm add clsx >/dev/null

# 9) Build + cola um resuminho
pnpm build 2>&1 | tee .last_build.log

echo "== Patch 2 aplicado! =="
echo "Teste agora:"
echo "  • Admin:    usuario=admin   senha=123456"
echo "  • Sponsor:  usuario=sponsor senha=000000"