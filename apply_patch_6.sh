#!/usr/bin/env bash
set -euo pipefail

echo "== PATCH 6: tema, layout, topbar/sidebar, login e settings =="

root="$(pwd)"

mkdir -p styles components/ui app/login app/settings

# 1) CSS tokens (sem color-mix, compatível com build)
cat > styles/tokens.css <<'CSS'
:root{
  /* Light (admin) */
  --accent:#00A7DD;
  --bg:#F5F7FA;
  --card:#FFFFFF;
  --surface:#F9FBFF;
  --text:#0B1524;
  --muted:#667085;
  --borderC:rgba(16,24,40,.10);
  --ring:rgba(0,167,221,.35);

  --radius:16px;
  --radius-lg:20px;
  --elev:0 10px 30px rgba(2,32,71,.08);
}
:root[data-theme="dark"]{
  /* Dark (sponsor) */
  --accent:#00A7DD;
  --bg:#0B1220;
  --card:#0F1627;
  --surface:#0C1322;
  --text:#E6E8EC;
  --muted:#9BA3AF;
  --borderC:rgba(255,255,255,.10);
  --ring:rgba(0,167,221,.50);
  --elev:0 14px 36px rgba(0,0,0,.35);
}

/* Base */
html,body{background:var(--bg);color:var(--text);}

/* Utilitárias simples */
.bg-card{background:var(--card);}
.bg-surface{background:var(--surface);}
.text-muted{color:var(--muted);}
.border{border:1px solid var(--borderC);}
.border-border{border-color:var(--borderC);}
.rounded-xl{border-radius:var(--radius);}
.rounded-2xl{border-radius:var(--radius-lg);}
.shadow-soft{box-shadow:var(--elev);}

/* Inputs */
.input{
  height:48px;width:100%;
  border:1px solid var(--borderC);
  background:var(--surface);
  border-radius:14px;
  padding:0 12px;
  outline:0;
  transition:border-color .15s ease, box-shadow .15s ease, background .15s ease;
}
.input:focus{
  border-color:var(--accent);
  box-shadow:0 0 0 4px var(--ring);
}

/* Botões base (fallback sem Tailwind) */
.btn{
  display:inline-flex;align-items:center;justify-content:center;
  gap:8px;height:44px;padding:0 18px;border-radius:9999px;
  border:1px solid transparent;cursor:pointer;
  background:var(--accent);color:white;font-weight:600;
  transition:transform .06s ease, box-shadow .15s ease, opacity .15s ease;
  box-shadow:0 6px 18px rgba(0,167,221,.25);
}
.btn:hover{opacity:.95;}
.btn:active{transform:translateY(1px);}
.btn-outline{
  background:transparent;color:var(--text);border-color:var(--borderC);
  box-shadow:none;
}
.btn-outline:hover{border-color:var(--accent);color:var(--accent);}
CSS

# 2) CSS global
cat > styles/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import "./tokens.css";

:root, :root[data-theme="dark"] { color-scheme: light dark; }
CSS

# 3) Button component (arredondado, contraste, foco)
mkdir -p components/ui
cat > components/ui/Button.tsx <<'TSX'
"use client";
import clsx from "clsx";
import { ButtonHTMLAttributes } from "react";

type Props = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "solid" | "outline";
  size?: "md" | "lg";
};

export default function Button({ className, variant="solid", size="md", ...props }: Props){
  return (
    <button
      {...props}
      className={clsx(
        "inline-flex items-center justify-center rounded-full transition",
        "focus:outline-none focus-visible:ring-4",
        variant==="solid"
          ? "bg-[var(--accent)] text-white shadow-[0_6px_18px_rgba(0,167,221,.25)] hover:opacity-95"
          : "bg-transparent text-[var(--text)] border border-[var(--borderC)] hover:border-[var(--accent)]",
        size==="lg" ? "h-12 px-6 text-[15px] font-semibold" : "h-11 px-5 text-[14px] font-semibold",
        className
      )}
      style={{ boxShadow: "var(--elev)" }}
    />
  );
}
TSX

# 4) Sidebar por perfil (recebe role do server)
cat > components/ui/Sidebar.tsx <<'TSX'
"use client";
import Link from "next/link";

export default function Sidebar({ role }: { role: "admin"|"sponsor" }){
  const items = role==="sponsor"
    ? [
        { href:"/sponsor/heineken/overview", label:"Overview" },
        { href:"/sponsor/heineken/results", label:"Resultados" },
        { href:"/sponsor/heineken/financials", label:"Financeiro" },
        { href:"/sponsor/heineken/events", label:"Eventos" },
        { href:"/sponsor/heineken/assets", label:"Assets" },
      ]
    : [
        { href:"/", label:"Overview" },
        { href:"/projetos", label:"Projetos" },
        { href:"/pipeline", label:"Pipeline" },
      ];
  return (
    <aside className="rounded-2xl border border-border bg-card p-4 shadow-soft">
      <nav className="space-y-3">
        {items.map((it)=>(
          <Link key={it.href} href={it.href}
            className="block rounded-xl border border-border bg-surface px-4 py-3 hover:shadow-soft transition">
            {it.label}
          </Link>
        ))}
        <Link href="/settings" className="block rounded-xl border border-border bg-surface px-4 py-3 hover:shadow-soft transition">Settings</Link>
      </nav>
    </aside>
  );
}
TSX

# 5) Topbar com logo e avatar (cliente; usa /api/logout)
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import { useState } from "react";

export default function Topbar({ role, brand }: { role:"admin"|"sponsor"; brand?: string }){
  const [loading, setLoading] = useState(false);

  async function logout(){
    setLoading(true);
    try{
      await fetch("/api/logout",{ method:"POST" });
      window.location.href = "/login";
    }finally{ setLoading(false); }
  }

  const showLogo = role==="sponsor" && brand;
  const logoSrc = brand ? `/logos/${brand}.png` : undefined;

  return (
    <header className="sticky top-0 z-30 bg-[var(--bg)]/80 backdrop-blur-md">
      <div className="mx-auto max-w-screen-2xl flex items-center justify-between p-4">
        <div className="flex items-center gap-3">
          <div className="h-3 w-3 rounded-full" style={{background:"var(--accent)"}}/>
          <span className="font-semibold">Engage Dashboard</span>
        </div>

        <div className="flex items-center gap-4">
          {showLogo && logoSrc ? (
            <Image src={logoSrc} alt={`${brand} logo`} width={88} height={24} priority />
          ) : null}

          <a href="/settings" className="flex items-center gap-2 rounded-full border border-border bg-card px-3 py-1.5 hover:shadow-soft">
            <div className="h-8 w-8 rounded-full bg-surface grid place-items-center border border-border">👤</div>
            <span className="text-sm text-muted hidden sm:inline">Perfil</span>
          </a>

          <button onClick={logout} disabled={loading}
            className="px-3 py-1.5 rounded-lg border text-sm hover:shadow-soft">
            {loading ? "Saindo..." : "Sair"}
          </button>
        </div>
      </div>
    </header>
  );
}
TSX

# 6) Root layout server: aplica tema no HTML por cookie (sem flicker) e mostra chrome padrão
cat > app/layout.tsx <<'TSX'
import "../styles/globals.css";
import type { Metadata } from "next";
import { cookies } from "next/headers";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }){
  const c = cookies();
  const role = (c.get("role")?.value === "sponsor" ? "sponsor" : "admin") as "admin"|"sponsor";
  const brand = c.get("brand")?.value;
  const theme = role === "sponsor" ? "dark" : undefined;

  return (
    <html lang="pt-BR" data-theme={theme}>
      <body>
        <Topbar role={role} brand={brand} />
        <div className="mx-auto grid max-w-screen-2xl grid-cols-[260px,1fr] gap-6 p-6">
          <Sidebar role={role} />
          <main className="min-h-[70vh]">{children}</main>
        </div>
      </body>
    </html>
  );
}
TSX

# 7) Layout exclusivo do /login (sem topbar/sidebar)
mkdir -p app/login
cat > app/login/layout.tsx <<'TSX'
import "../../styles/globals.css";

export const metadata = { title: "Login • Engage" };

export default function LoginLayout({ children }: { children: React.ReactNode }){
  return (
    <html lang="pt-BR">
      <body className="min-h-screen grid place-items-center p-6">{children}</body>
    </html>
  );
}
TSX

# 8) Página de Login (visual + chamada à /api/auth)
cat > app/login/page.tsx <<'TSX'
"use client";
import { useState, useEffect } from "react";
import Button from "@/components/ui/Button";

type Role = "admin" | "sponsor";

export default function Page(){
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(()=>{ setUsername("admin"); setPassword("123456"); },[]);

  function brandFromUser(u:string){ return u.toLowerCase()==="sponsor" ? "heineken" : "acme"; }

  async function onSubmit(e:React.FormEvent){
    e.preventDefault();
    const ok =
      (role==="admin" && username==="admin" && password==="123456") ||
      (role==="sponsor" && username==="sponsor" && password==="000000");
    if(!ok){ alert("Usuário ou senha inválidos"); return; }

    setLoading(true);
    const brand = role==="sponsor" ? brandFromUser(username) : undefined;
    const resp = await fetch("/api/auth", {
      method:"POST",
      headers:{ "content-type":"application/json" },
      body: JSON.stringify({ role, brand })
    });
    setLoading(false);
    if(!resp.ok){ alert("Falha ao autenticar"); return; }

    if(role==="sponsor") window.location.href = `/sponsor/${brand}/overview`;
    else window.location.href = "/";
  }

  return (
    <main className="w-full max-w-4xl">
      <div className="grid md:grid-cols-2 gap-4 mb-6">
        <button type="button" onClick={()=>{ setRole("admin"); setUsername("admin"); setPassword("123456"); }}
          className={`text-left rounded-2xl border px-5 py-4 bg-card hover:shadow-soft transition ${role==="admin"?"ring-2 ring-[var(--accent)]":""}`}>
          <div className="text-sm text-muted">Perfil</div>
          <div className="mt-1 font-semibold">Interno (Admin)</div>
          <div className="text-sm text-muted mt-1">Acesso completo</div>
        </button>

        <button type="button" onClick={()=>{ setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}
          className={`text-left rounded-2xl border px-5 py-4 bg-card hover:shadow-soft transition ${role==="sponsor"?"ring-2 ring-[var(--accent)]":""}`}>
          <div className="text-sm text-muted">Perfil</div>
          <div className="mt-1 font-semibold">Patrocinador</div>
          <div className="text-sm text-muted mt-1">Acesso ao próprio contrato</div>
        </button>
      </div>

      <form onSubmit={onSubmit} className="rounded-2xl border bg-card p-6 shadow-soft space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <label className="block">
            <div className="text-sm mb-1">Usuário</div>
            <input className="input" value={username} onChange={(e)=>setUsername(e.target.value)}
              placeholder={role==="admin"?"admin":"sponsor"} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">Senha</div>
            <input className="input" type="password" value={password} onChange={(e)=>setPassword(e.target.value)}
              placeholder={role==="admin"?"123456":"000000"} />
          </label>
        </div>

        <div className="flex gap-3 pt-2">
          <Button type="submit" size="lg">{loading ? "Entrando..." : "Entrar"}</Button>
          <Button type="button" variant="outline" onClick={()=>{
            if(role==="admin"){ setUsername("admin"); setPassword("123456"); }
            else { setUsername("sponsor"); setPassword("000000"); }
          }}>Preencher exemplo</Button>
        </div>
      </form>
    </main>
  );
}
TSX

# 9) Settings page (form simples salvo em localStorage)
cat > app/settings/page.tsx <<'TSX'
"use client";
import { useEffect } from "react";
import { useForm } from "react-hook-form";
import Button from "@/components/ui/Button";

type FormData = {
  companyName: string;
  cnpj: string;
  email: string;
  phone: string;
};

export default function SettingsPage(){
  const { register, handleSubmit, reset } = useForm<FormData>({
    defaultValues: { companyName:"", cnpj:"", email:"", phone:"" }
  });

  useEffect(()=>{
    try{
      const raw = localStorage.getItem("settings");
      if(raw) reset(JSON.parse(raw));
    }catch{}
  },[reset]);

  function onSubmit(data:FormData){
    localStorage.setItem("settings", JSON.stringify(data));
    alert("Dados salvos!");
  }

  return (
    <section className="rounded-2xl border bg-card p-6 shadow-soft">
      <h1 className="text-xl font-semibold mb-4">Settings</h1>
      <form onSubmit={handleSubmit(onSubmit)} className="grid gap-4 md:grid-cols-2">
        <label className="block">
          <div className="text-sm mb-1">Nome da empresa</div>
          <input className="input" {...register("companyName")} placeholder="Entourage" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">CNPJ</div>
          <input className="input" {...register("cnpj")} placeholder="00.000.000/0001-00" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">E-mail</div>
          <input className="input" type="email" {...register("email")} placeholder="contato@empresa.com" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">Telefone</div>
          <input className="input" {...register("phone")} placeholder="(11) 99999-9999" />
        </label>
        <div className="md:col-span-2 pt-2">
          <Button type="submit" size="lg">Salvar</Button>
        </div>
      </form>
    </section>
  );
}
TSX

# 10) Garante logo demo
mkdir -p public/logos
# (assume heineken.png já existe no repo; se existir na raiz, move)
[ -f heineken.png ] && mv -f heineken.png public/logos/heineken.png || true

echo "== Instalando e buildando =="
pnpm install --silent
rm -rf .next static/css || true
pnpm build | tee .last_build.log

echo
echo "== PRONTO =="
echo "• Teste /login:"
echo "   - Admin:    usuario=admin   senha=123456"
echo "   - Sponsor:  usuario=sponsor senha=000000"
echo "• Depois confira /settings (avatar no topo leva pra lá)."
