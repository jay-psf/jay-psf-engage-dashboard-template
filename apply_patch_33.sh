set -euo pipefail

echo "== Patch 33: Topbar glass + Login deslizante + Users (admin) + Forgot =="

# 0) Pastas
mkdir -p styles components/ui components/lib app/login app/admin/users app/forgot-password app/sponsor/[brand] public/logos

# 1) Tokens (cores/light/dark + helpers de vidro/efeitos)
cat > styles/tokens.css <<'CSS'
:root{
  /* Brand */
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;

  /* Light */
  --bg:#F6F8FB; --card:#FFFFFF; --surface:#F2F4F9;
  --text:#0B1524; --muted:#667085; --borderC:rgba(16,24,40,.12);

  /* Dark */
  --bg-dark:#0B1220; --card-dark:#0B0F1A; --surface-dark:#0A0E18;
  --text-dark:#E6E8EC; --muted-dark:#9BA3AF; --borderC-dark:rgba(255,255,255,.10);

  /* Raio & sombras */
  --radius:16px; --radius-lg:22px;
  --elev:0 10px 30px rgba(2,32,71,.08);
  --elev-strong:0 18px 50px rgba(2,32,71,.16);
  --elev-dark:0 18px 46px rgba(0,0,0,.50);

  /* Halos */
  --ring:rgba(126,58,242,.40);
  --ring-strong:rgba(126,58,242,.70);

  /* Glass */
  --glass-bg: rgba(255,255,255,.60);
  --glass-brd: rgba(255,255,255,.35);
  --glass-bg-dark: rgba(8,10,18,.55);
  --glass-brd-dark: rgba(255,255,255,.10);
}

/* Tema dark aplicado via [data-theme] no <html> */
:root[data-theme="dark"]{
  --bg:var(--bg-dark); --card:var(--card-dark); --surface:var(--surface-dark);
  --text:var(--text-dark); --muted:var(--muted-dark); --borderC:var(--borderC-dark);
}

html,body{ background:var(--bg); color:var(--text); min-height:100%; }

/* utilitários simples */
.bg-card{ background:var(--card); }
.bg-surface{ background:var(--surface); }
.text-muted{ color:var(--muted); }
.border{ border:1px solid var(--borderC); }
.border-border{ border-color:var(--borderC); }
.rounded-xl{ border-radius:var(--radius); }
.rounded-2xl{ border-radius:var(--radius-lg); }
.shadow-soft{ box-shadow:var(--elev); }
.shadow-strong{ box-shadow:var(--elev-strong); }

/* GLASS */
.glass {
  position: sticky; top:0; z-index:50;
  backdrop-filter:saturate(160%) blur(12px);
  background: var(--glass-bg);
  border-bottom:1px solid var(--glass-brd);
}
:root[data-theme="dark"] .glass{
  background: var(--glass-bg-dark);
  border-bottom:1px solid var(--glass-brd-dark);
  box-shadow:0 10px 35px rgba(0,0,0,.25);
}

/* Botão base com glow sutil porém impactante */
.btn{
  display:inline-flex; align-items:center; gap:.5rem;
  height:42px; padding:0 16px; border-radius:999px;
  border:1px solid var(--borderC); background:var(--card); color:var(--text);
  transition:transform .12s ease, box-shadow .12s ease, background .2s ease, border-color .2s ease;
}
:root[data-theme="dark"] .btn{ background: #0F1322; border-color:var(--borderC-dark); }
.btn:hover{
  transform:translateY(-1px);
  box-shadow:0 8px 30px rgba(126,58,242,.20), 0 0 0 8px var(--ring);
  border-color: var(--accent-600);
}
.btn:active{ transform:translateY(0); box-shadow:0 4px 14px rgba(126,58,242,.18); }
.btn-primary{ background:var(--accent); color:white; border-color:transparent; }
.btn-primary:hover{ box-shadow:0 10px 34px rgba(126,58,242,.35), 0 0 0 10px var(--ring); }

.btn-outline{ background:transparent; }
.btn-muted{ background:var(--surface); }
:root[data-theme="dark"] .btn-muted{ background:#0C1221; }

.input{
  height:46px; width:100%; border:1px solid var(--borderC);
  background:var(--surface); border-radius:14px; padding:0 14px;
}
:root[data-theme="dark"] .input{ background:#0C1221; border-color:var(--borderC-dark); }
CSS

# 2) globals.css (importado pelo layout)
cat > styles/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import "./tokens.css";

:root, html, body{ font-feature-settings:"ss01","cv08"; }
a { text-decoration:none; color:inherit; }
.container{ width:100%; max-width:1200px; margin:0 auto; padding:0 16px; }
CSS

# 3) Helper de sessão central
mkdir -p components/lib
cat > components/lib/session.ts <<'TS'
"use client";

export type Role = "admin" | "sponsor";
export type ThemePref = "light" | "dark" | "system";
export type Session = { role?: Role; brand?: string; username?: string };

export function readCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  const escaped = name.replace(/([.$?*|{}()[\]\\/+^])/g,"\\$1");
  const re = new RegExp("(?:^|; )"+escaped+"=([^;]*)");
  const m = document.cookie.match(re);
  return m ? decodeURIComponent(m[1]) : undefined;
}

export function readSession(): Session {
  if (typeof document === "undefined") return {};
  return {
    role: (readCookie("role") as Role | undefined),
    brand: readCookie("brand") || undefined,
    username: readCookie("username") || undefined,
  };
}

export function resolveBrandLogo(brand?: string){
  const b = (brand || "acme").toLowerCase();
  return `/logos/${b}.png`;
}
TS

# 4) Topbar unificada (glass), sem duplicação de menu, logos com navegação
cat > components/ui/Topbar.tsx <<'TSX'
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
TSX

# 5) ClientShell – aplica tema e oculta chrome no /login
cat > components/ClientShell.tsx <<'TSX'
"use client";
import { useEffect } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import { readSession } from "@/components/lib/session";

export default function ClientShell({ children }: { children: React.ReactNode }){
  const pathname = usePathname();
  const { role } = readSession();

  useEffect(()=> {
    const pref = (typeof window !== "undefined") ? localStorage.getItem("themePref") : null;
    const html = document.documentElement;
    const desired = pref ?? (role === "sponsor" ? "dark" : "light");
    if (desired === "dark") html.setAttribute("data-theme","dark");
    else if (desired === "light") html.removeAttribute("data-theme");
    else {
      const mq = window.matchMedia("(prefers-color-scheme: dark)");
      if (mq.matches) html.setAttribute("data-theme","dark"); else html.removeAttribute("data-theme");
    }
  }, [role]);

  const isLogin = pathname === "/login";
  return (
    <>
      {!isLogin && <Topbar />}
      <main className={isLogin ? "" : "pt-[72px]"}>{children}</main>
    </>
  );
}
TSX

# 6) Layout raiz – corrige import do globals.css
cat > app/layout.tsx <<'TSX'
import "@/styles/globals.css";
import ClientShell from "@/components/ClientShell";

export const metadata = { title: "Engage" };

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

# 7) Login (seletor deslizante Admin/Sponsor + link esqueci)
cat > app/login/page.tsx <<'TSX'
import type { Metadata } from "next";
import LoginForm from "./login-form";

export const metadata: Metadata = { title: "Login • Engage" };

export default function Page() {
  return (
    <main className="min-h-[calc(100vh-64px)] grid place-items-center px-4">
      <div className="w-full max-w-xl">
        <h1 className="sr-only">Entrar</h1>
        <LoginForm />
      </div>
    </main>
  );
}
TSX

cat > app/login/login-form.tsx <<'TSX'
"use client";
import { useState, useEffect } from "react";
import Link from "next/link";

type Role = "admin" | "sponsor";

export default function LoginForm(){
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState(""); const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(()=>{ setUsername("admin"); setPassword("123456"); },[]);

  const brandFromUser = (u:string) => u.toLowerCase()==="sponsor" ? "heineken" : "acme";

  async function onSubmit(e: React.FormEvent){
    e.preventDefault();
    const ok = (role==="admin" && username==="admin" && password==="123456")
            || (role==="sponsor" && username==="sponsor" && password==="000000");
    if(!ok){ alert("Usuário ou senha inválidos"); return; }

    setLoading(true);
    const brand = role==="sponsor" ? brandFromUser(username) : undefined;
    const resp = await fetch("/api/auth",{
      method:"POST", headers:{ "content-type":"application/json" },
      body: JSON.stringify({ role, brand }),
    });
    setLoading(false);
    if(!resp.ok){ alert("Falha ao autenticar"); return; }
    window.location.href = role==="sponsor" ? `/sponsor/${brand}/overview` : "/";
  }

  return (
    <div className="bg-card rounded-2xl shadow-strong border border-border p-6">
      <div className="mb-5">
        <div className="text-sm text-muted font-medium mb-2">Entrar como</div>
        <div className="relative bg-surface rounded-full p-1 border border-border flex">
          <button type="button"
            className={`flex-1 h-10 rounded-full transition ${role==="admin" ? "bg-[var(--accent)] text-white" : ""}`}
            onClick={()=>{ setRole("admin"); setUsername("admin"); setPassword("123456"); }}>
            Admin
          </button>
          <button type="button"
            className={`flex-1 h-10 rounded-full transition ${role==="sponsor" ? "bg-[var(--accent)] text-white" : ""}`}
            onClick={()=>{ setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}>
            Patrocinador
          </button>
        </div>
      </div>

      <form onSubmit={onSubmit} className="space-y-4">
        <label className="block">
          <div className="text-sm mb-1">Usuário</div>
          <input value={username} onChange={e=>setUsername(e.target.value)} className="input" placeholder={role==="admin"?"admin":"sponsor"} />
        </label>
        <label className="block">
          <div className="text-sm mb-1">Senha</div>
          <input value={password} onChange={e=>setPassword(e.target.value)} className="input" type="password" placeholder={role==="admin"?"123456":"000000"} />
        </label>

        <div className="flex items-center justify-between">
          <button type="submit" className="btn btn-primary">{loading ? "Entrando..." : "Entrar"}</button>
          <Link href="/forgot-password" className="text-sm text-[var(--accent)] hover:underline">Esqueci minha senha</Link>
        </div>
      </form>
    </div>
  );
}
TSX

# 8) Forgot password (mock)
cat > app/forgot-password/page.tsx <<'TSX'
export const metadata = { title: "Recuperar senha • Engage" };

export default function ForgotPassword(){
  return (
    <main className="min-h-[calc(100vh-64px)] grid place-items-center px-4">
      <div className="bg-card rounded-2xl shadow-soft border border-border p-6 w-full max-w-lg">
        <h1 className="text-xl font-semibold mb-2">Recuperar senha</h1>
        <p className="text-sm text-muted mb-4">Informe seu e-mail. Enviaremos instruções (demo).</p>
        <form onSubmit={(e)=>{ e.preventDefault(); alert("Se existisse backend, enviaríamos o e-mail 😄"); }}>
          <input className="input mb-3" placeholder="email@empresa.com" type="email" required />
          <button className="btn btn-primary" type="submit">Enviar</button>
        </form>
      </div>
    </main>
  );
}
TSX

# 9) Admin > Users (mock CRUD local)
cat > app/admin/users/page.tsx <<'TSX'
"use client";
import { useState } from "react";

type Role = "admin" | "sponsor";
type U = { id: string; name: string; email: string; role: Role };

export default function AdminUsers(){
  const [list, setList] = useState<U[]>([
    { id:"1", name:"Admin Demo", email:"admin@engage.com", role:"admin" },
    { id:"2", name:"Sponsor Demo", email:"contact@heineken.com", role:"sponsor" },
  ]);
  const [name,setName]=useState(""); const [email,setEmail]=useState(""); const [role,setRole]=useState<Role>("sponsor");

  function addUser(e:React.FormEvent){ e.preventDefault();
    const id = String(Date.now());
    setList(prev=>[...prev,{ id, name, email, role }]);
    setName(""); setEmail(""); setRole("sponsor");
  }
  function remove(id:string){ setList(prev=>prev.filter(x=>x.id!==id)); }

  return (
    <div className="container py-6">
      <h1 className="text-2xl font-semibold mb-4">Usuários</h1>
      <form onSubmit={addUser} className="bg-card rounded-2xl border border-border p-4 shadow-soft grid md:grid-cols-4 gap-3 mb-6">
        <input className="input" placeholder="Nome" value={name} onChange={e=>setName(e.target.value)} />
        <input className="input" placeholder="E-mail" value={email} onChange={e=>setEmail(e.target.value)} />
        <select className="input" value={role} onChange={e=>setRole(e.target.value as Role)}>
          <option value="sponsor">Patrocinador</option>
          <option value="admin">Admin</option>
        </select>
        <button className="btn btn-primary">Adicionar</button>
      </form>

      <div className="bg-card rounded-2xl border border-border shadow-soft overflow-hidden">
        <table className="w-full text-sm">
          <thead className="text-muted">
            <tr><th className="text-left p-3">Nome</th><th className="text-left p-3">E-mail</th><th className="text-left p-3">Papel</th><th className="p-3"></th></tr>
          </thead>
          <tbody>
            {list.map(u=>(
              <tr key={u.id} className="border-t border-border">
                <td className="p-3">{u.name}</td>
                <td className="p-3">{u.email}</td>
                <td className="p-3 capitalize">{u.role}</td>
                <td className="p-3 text-right"><button className="btn btn-outline" onClick={()=>remove(u.id)}>Remover</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
TSX

# 10) Garante uma logo demo
[ -f public/logos/heineken.png ] || echo -n "" > public/logos/heineken.png
[ -f public/logos/acme.png ] || echo -n "" > public/logos/acme.png

# 11) Build
pnpm build

echo "== Patch 33 aplicado! =="
echo "Teste rápido:"
echo "  • Login admin:    admin / 123456"
echo "  • Login sponsor:  sponsor / 000000"
