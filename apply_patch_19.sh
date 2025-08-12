set -euo pipefail

echo "== Patch 19: menus (light), logout sólido, login polido, logo 2.5x =="

# 1) Tokens estáveis + estilos utilitários (.navpill/.btn) com contraste bom no light e dark
cat > styles/tokens.css <<'CSS'
:root{
  /* Roxo Entourage */
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;

  /* Light */
  --bg:#F6F8FB; --surface:#FFFFFF; --card:#FFFFFF;
  --text:#0B1524; --muted:#606B85; --borderC:rgba(16,24,40,.14);
  --ring:rgba(126,58,242,.35);

  --radius:16px; --radius-lg:20px; --elev:0 12px 28px rgba(2,32,71,.08);
}
:root[data-theme="dark"]{
  --bg:#0B0F17; --surface:#0E131D; --card:#0E131D;
  --text:#E9EDF5; --muted:#99A2B0; --borderC:rgba(255,255,255,.10);
  --ring:rgba(126,58,242,.55);
  --elev:0 16px 36px rgba(0,0,0,.45);
}
html,body{background:var(--bg);color:var(--text)}
.bg-card{background:var(--card)} .bg-surface{background:var(--surface)}
.text-muted{color:var(--muted)} .border{border:1px solid var(--borderC)}
.border-border{border-color:var(--borderC)}
.rounded-xl{border-radius:var(--radius)} .rounded-2xl{border-radius:var(--radius-lg)}
.shadow-soft{box-shadow:var(--elev)}

/* Navegação lateral como pílulas */
.navpill{
  display:flex;align-items:center;gap:.625rem;height:56px;
  padding:0 18px;border-radius:9999px;
  border:1px solid var(--borderC); background:var(--surface);
  transition:background .2s ease,box-shadow .2s ease,border-color .2s ease,transform .06s ease;
}
.navpill:hover{box-shadow:0 0 0 4px var(--ring);border-color:transparent}
.navpill:active{transform:translateY(1px)}
.navpill--active{background:var(--accent);color:#fff;border-color:transparent}

/* Botões */
.btn{
  display:inline-flex;align-items:center;justify-content:center;gap:.5rem;
  height:44px;padding:0 18px;border-radius:9999px;border:1px solid var(--borderC);
  background:var(--surface);color:var(--text);
  transition:box-shadow .2s ease,transform .06s ease,background .2s ease,border-color .2s ease;
}
.btn:hover{box-shadow:0 0 0 4px var(--ring)}
.btn:active{transform:translateY(1px)}
.btn-primary{background:var(--accent);color:#fff;border-color:transparent}
.btn-outline{background:transparent}

/* Inputs e Cards */
.input{height:46px;width:100%;border:1px solid var(--borderC);border-radius:14px;background:var(--surface);padding:0 12px}
.card{background:var(--surface);border:1px solid var(--borderC);border-radius:18px;box-shadow:var(--elev)}
CSS

# 2) Topbar – usa somente o logo (2.5x ~ 48px) quando sponsor e corrige logout
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";
import { readSession } from "@/components/lib/session";

export default function Topbar() {
  const [{role, brand}, setS] = useState<{role?: "admin"|"sponsor"; brand?: string}>({});
  useEffect(()=>{ setS(readSession()); }, []);

  async function logout() {
    try { await fetch("/api/logout", { method: "POST" }); } catch {}
    try { localStorage.removeItem("engage_theme"); } catch {}
    document.cookie = "role=; Max-Age=0; path=/";
    document.cookie = "brand=; Max-Age=0; path=/";
    window.location.href = "/login";
  }

  const brandLogo = brand ? `/logos/${brand.toLowerCase()}.png` : undefined;

  return (
    <header className="sticky top-0 z-30 bg-[var(--bg)]/85 backdrop-blur border-b border-border">
      <div className="mx-auto max-w-screen-2xl px-4 py-3 flex items-center gap-3">
        <Link href="/" className="mr-auto font-semibold">Engage</Link>

        {/* Brand pill (apenas logo) para sponsor */}
        {role==="sponsor" && brandLogo && (
          <div className="hidden sm:flex items-center h-10 px-3 rounded-full border border-border bg-surface">
            <Image src={brandLogo} alt="brand" width={48} height={48} className="rounded-md block" />
          </div>
        )}

        <Link href={role==="sponsor" ? `/sponsor/${brand ?? "acme"}/settings` : "/settings"} className="btn">Perfil</Link>
        <button type="button" className="btn btn-outline" onClick={logout}>Sair</button>
      </div>
    </header>
  );
}
TSX

# 3) Sidebar – usa .navpill e envia para settings correto no modo sponsor
cat > components/ui/Sidebar.tsx <<'TSX'
"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { readSession } from "@/components/lib/session";

const items = [
  { href: "/overview", label: "Overview" },
  { href: "/results",  label: "Resultados" },
  { href: "/financials", label: "Financeiro" },
  { href: "/events", label: "Eventos" },
  { href: "/assets", label: "Assets" },
  { href: "/settings", label: "Settings" },
];

export default function Sidebar() {
  const p = usePathname();
  const { role, brand } = readSession();

  function resolveHref(h: string) {
    if (role==="sponsor") {
      if (h==="/settings") return `/sponsor/${brand ?? "acme"}/settings`;
      return `/sponsor/${brand ?? "acme"}${h}`;
    }
    if (h==="/overview") return "/";
    return h;
  }

  return (
    <aside className="w-full max-w-[320px]">
      <nav className="flex flex-col gap-4">
        {items.map(it=>{
          const href = resolveHref(it.href);
          const active = p===href || (it.href==="/overview" && p==="/");
          return (
            <Link
              key={it.href}
              href={href}
              className={`navpill ${active ? "navpill--active" : ""}`}
            >
              {it.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
TSX

# 4) Login – layout e contraste estáveis
cat > app/login/login-form.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => { setUsername("admin"); setPassword("123456"); }, []);

  function brandFromUser(u: string) { return u.toLowerCase()==="sponsor" ? "heineken" : "acme"; }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    const ok = (role==="admin" && username==="admin" && password==="123456") ||
               (role==="sponsor" && username==="sponsor" && password==="000000");
    if (!ok) return alert("Usuário ou senha inválidos");

    setLoading(true);
    const brand = role==="sponsor" ? brandFromUser(username) : undefined;
    await fetch("/api/auth", { method:"POST", headers:{ "content-type":"application/json" }, body: JSON.stringify({ role, brand }) }).catch(()=>{});
    setLoading(false);

    window.location.href = role==="sponsor" ? `/sponsor/${brand}/overview` : "/";
  }

  return (
    <div className="min-h-[calc(100vh-64px)] grid place-items-center px-4">
      <div className="w-full max-w-4xl space-y-6">
        <div className="grid md:grid-cols-2 gap-4">
          <button type="button"
            onClick={()=>{ setRole("admin"); setUsername("admin"); setPassword("123456"); }}
            className={`card p-5 text-left ${role==="admin" ? "ring-4 ring-[var(--ring)]" : ""}`}>
            <div className="text-sm text-muted">Perfil</div>
            <div className="mt-1 font-semibold">Interno (Admin)</div>
            <div className="text-sm text-muted mt-1">Acesso completo</div>
          </button>
          <button type="button"
            onClick={()=>{ setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}
            className={`card p-5 text-left ${role==="sponsor" ? "ring-4 ring-[var(--ring)]" : ""}`}>
            <div className="text-sm text-muted">Perfil</div>
            <div className="mt-1 font-semibold">Patrocinador</div>
            <div className="text-sm text-muted mt-1">Acesso ao próprio contrato</div>
          </button>
        </div>

        <form onSubmit={onSubmit} className="card p-6 space-y-4">
          <div className="grid md:grid-cols-2 gap-4">
            <label className="block">
              <div className="text-sm mb-1">Usuário</div>
              <input className="input" placeholder={role==="admin"?"admin":"sponsor"}
                     value={username} onChange={(e)=>setUsername(e.target.value)} />
            </label>
            <label className="block">
              <div className="text-sm mb-1">Senha</div>
              <input className="input" type="password" placeholder={role==="admin"?"123456":"000000"}
                     value={password} onChange={(e)=>setPassword(e.target.value)} />
            </label>
          </div>
          <div className="flex gap-3 pt-2">
            <button type="submit" className="btn btn-primary">{loading?"Entrando...":"Entrar"}</button>
            <button type="button" className="btn"
              onClick={()=>{ if(role==="admin"){setUsername("admin");setPassword("123456");}
                             else{setUsername("sponsor");setPassword("000000");}}}>
              Preencher exemplo
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
TSX

echo "== Build =="
pnpm build
