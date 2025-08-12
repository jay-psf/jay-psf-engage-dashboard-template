#!/usr/bin/env bash
set -euo pipefail

echo "== 0) Preparando pastas =="
mkdir -p styles components/ui app/login public/logos components

echo "== 1) CSS de tokens (cores/tipografia) =="
cat > styles/tokens.css <<'CSS'
:root{
  --accent:#00A7DD;
  --bg:#F6F8FB;
  --card:#FFFFFF;
  --text:#0B1524;
  --muted:#667085;
  --ring:#00A7DD33;
  --border-color:rgba(16,24,40,0.10);
}
:root[data-theme="dark"]{
  --accent:#00A7DD;
  --bg:#0B1220;
  --card:#111827;
  --text:#E6E8EC;
  --muted:#9BA3AF;
  --ring:#00A7DD55;
  --border-color:rgba(255,255,255,0.12);
}
html,body{background:var(--bg);color:var(--text);}
.text-muted{color:var(--muted);}
.bg-card{background:var(--card);}
.shadow-soft{box-shadow:0 8px 30px rgba(2,32,71,.08);}
.border{border:1px solid var(--border-color);}
.ring-accent{box-shadow:0 0 0 3px var(--ring);}
CSS

echo "== 2) CSS global (Tailwind + importa tokens) =="
cat > styles/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import "./tokens.css";

:root, :root[data-theme="dark"] { color-scheme: light dark; }

button:focus-visible, a:focus-visible { outline: none; box-shadow: 0 0 0 3px var(--ring); border-radius: 14px; }
CSS

echo "== 3) Botão estilizado =="
cat > components/ui/Button.tsx <<'TSX'
"use client";
import React from "react";
import clsx from "clsx";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary"|"outline"|"ghost";
  size?: "sm"|"md"|"lg";
};

export default function Button({variant="primary", size="md", className, ...rest}:Props){
  const base = "inline-flex items-center justify-center rounded-xl font-medium transition";
  const byVariant = {
    primary: "bg-[var(--accent)] text-white hover:opacity-90",
    outline: "border text-[var(--text)] bg-card hover:bg-white/50",
    ghost: "text-[var(--text)] hover:bg-white/30"
  }[variant];
  const bySize = {
    sm:"h-9 px-3 text-sm",
    md:"h-11 px-4",
    lg:"h-12 px-6 text-base"
  }[size];
  return <button className={clsx("border", base, byVariant, bySize, className)} {...rest} />;
}
TSX

echo "== 4) Topbar (mostra logo no modo sponsor) =="
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import Link from "next/link";
import Button from "./Button";
import { useEffect, useState } from "react";

type Session = { role?: "admin"|"sponsor"; brand?: string; username?: string };

function readSession(): Session {
  try { const raw = localStorage.getItem("session"); return raw? JSON.parse(raw):{}; }
  catch { return {}; }
}

export default function Topbar(){
  const [s,setS] = useState<Session>({});
  useEffect(()=>{ setS(readSession()); },[]);
  const isSponsor = s.role==="sponsor";
  const brand = s.brand || "heineken"; // demo default
  return (
    <header className="sticky top-0 z-20 border bg-card backdrop-blur supports-[backdrop-filter]:bg-card/85">
      <div className="mx-auto max-w-screen-2xl h-16 px-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          {isSponsor ? (
            <Image
              src={`/logos/${brand}.png`}
              alt={`${brand} logo`}
              width={110}
              height={24}
              className="object-contain"
              priority
            />
          ) : (
            <Link href="/" className="text-lg font-semibold">Entourage • Engage</Link>
          )}
        </div>
        <nav className="flex items-center gap-2">
          <Button
            variant="outline"
            onClick={()=>{
              localStorage.removeItem("session");
              document.documentElement.removeAttribute("data-theme");
              window.location.href="/login";
            }}
          >Sair</Button>
        </nav>
      </div>
    </header>
  );
}
TSX

echo "== 5) Sidebar (menus por perfil) =="
cat > components/ui/Sidebar.tsx <<'TSX'
"use client";
import Link from "next/link";
import { useEffect, useState } from "react";

type Session = { role?: "admin"|"sponsor"; brand?: string };
function readSession(): Session {
  try { const raw = localStorage.getItem("session"); return raw? JSON.parse(raw):{}; }
  catch { return {}; }
}

const Item = ({href, children}:{href:string; children:React.ReactNode})=>(
  <Link href={href} className="block rounded-xl border bg-card px-4 py-3 hover:shadow-soft transition">
    {children}
  </Link>
);

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
            <Item href={`/sponsor/${brand}/overview`}>Visão Geral</Item>
            <Item href={`/sponsor/${brand}/events`}>Eventos</Item>
            <Item href={`/sponsor/${brand}/results`}>Resultados</Item>
            <Item href={`/sponsor/${brand}/financials`}>Financeiro</Item>
            <Item href={`/sponsor/${brand}/assets`}>Assets</Item>
          </>
        ) : (
          <>
            <Item href="/">Dashboard</Item>
            <Item href="/pipeline">Pipeline</Item>
            <Item href="/projetos">Projetos</Item>
            <Item href="/admin">Admin</Item>
          </>
        )}
      </div>
    </aside>
  );
}
TSX

echo "== 6) ClientShell: oculta chrome na rota /login e aplica tema =="
cat > components/ClientShell.tsx <<'TSX'
"use client";
import { usePathname } from "next/navigation";
import { useEffect, useMemo } from "react";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

type Session = { role?: "admin"|"sponsor"; brand?: string };
function readSession(): Session {
  try { const raw = localStorage.getItem("session"); return raw? JSON.parse(raw):{}; }
  catch { return {}; }
}

export default function ClientShell({children}:{children:React.ReactNode}){
  const path = usePathname();
  const isLogin = path.startsWith("/login");

  const role = useMemo(() => readSession().role ?? "admin", [isLogin]);
  useEffect(()=>{
    const s = readSession();
    if(s.role==="sponsor") document.documentElement.setAttribute("data-theme","dark");
    else document.documentElement.removeAttribute("data-theme");
  },[path]);

  if(isLogin) return <main className="min-h-screen grid place-items-center px-4">{children}</main>;

  return (
    <>
      <Topbar />
      <div className="mx-auto max-w-screen-2xl grid grid-cols-[260px,1fr] gap-6 p-6">
        <Sidebar />
        <main className="min-h-[70vh]">{children}</main>
      </div>
    </>
  );
}
TSX

echo "== 7) Root layout simples que usa o ClientShell =="
cat > app/layout.tsx <<'TSX'
import "../styles/globals.css";
import "../styles/tokens.css";
import type { Metadata } from "next";
import ClientShell from "@/components/ClientShell";

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR">
      <body>
        <ClientShell>{children}</ClientShell>
      </body>
    </html>
  );
}
TSX

echo "== 8) Login (dois perfis, sem campo de brand) =="
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
    <div className="w-full max-w-4xl mx-auto space-y-6">
      <div className="grid md:grid-cols-2 gap-4">
        <button onClick={()=>setRole("admin")}
          className={`text-left rounded-2xl border px-5 py-4 bg-card hover:shadow-soft transition ${role==="admin"?"ring-accent":""}`}>
          <div className="text-sm text-muted">Perfil</div>
          <div className="mt-1 font-semibold">Interno (Admin)</div>
          <div className="text-sm text-muted mt-1">Acesso completo</div>
        </button>

        <button onClick={()=>setRole("sponsor")}
          className={`text-left rounded-2xl border px-5 py-4 bg-card hover:shadow-soft transition ${role==="sponsor"?"ring-accent":""}`}>
          <div className="text-sm text-muted">Perfil</div>
          <div className="mt-1 font-semibold">Patrocinador</div>
          <div className="text-sm text-muted mt-1">Acompanha seu contrato</div>
        </button>
      </div>

      <form onSubmit={onSubmit} className="rounded-2xl border bg-card p-6 shadow-soft space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <label className="block">
            <div className="text-sm mb-1">Usuário</div>
            <input value={username} onChange={(e)=>setUsername(e.target.value)}
              className="w-full h-11 rounded-xl border bg-white/60 px-3" placeholder={role==="admin"?"admin":"sponsor"} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">Senha</div>
            <input value={password} onChange={(e)=>setPassword(e.target.value)}
              className="w-full h-11 rounded-xl border bg-white/60 px-3" placeholder={role==="admin"?"123456":"000000"} type="password" />
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

cat > app/login/page.tsx <<'TSX'
import type { Metadata } from "next";
import LoginForm from "./login-form";

export const metadata: Metadata = { title: "Login • Engage" };

export default function Page(){
  return (
    <main className="w-full px-4">
      <h1 className="sr-only">Entrar</h1>
      <LoginForm />
    </main>
  );
}
TSX

echo "== 9) Logo demo (Heineken). Se existir em raiz, move para public/logos =="
if [ -f heineken.png ] && [ ! -f public/logos/heineken.png ]; then
  mv -f heineken.png public/logos/heineken.png || true
fi

echo "== 10) Dependência utilitária =="
pnpm add clsx >/dev/null

echo "== 11) Build =="
pnpm build

echo "== FEITO! =="
echo "Teste no navegador:"
echo "  • Admin:    usuario=admin   senha=123456"
echo "  • Sponsor:  usuario=sponsor senha=000000"