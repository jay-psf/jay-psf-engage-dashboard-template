set -euo pipefail

echo "== Patch 20: menu light OK, sponsor dark 100%, logo maior, logout sólido, settings sponsor, login polido =="

# 1) Tokens estáveis (light/dark) + utilitários de navegação e glow em botões
cat > styles/tokens.css <<'CSS'
:root {
  /* Brand roxo */
  --accent: #7E3AF2;
  --accent-600: #6C2BD9;
  --accent-700: #5B21B6;

  /* Light */
  --bg: #F6F8FB;
  --card: #FFFFFF;
  --surface: #F2F4F9;
  --text: #0B1524;
  --muted: #667085;
  --borderC: #E4E7EC;

  /* Raio e sombra */
  --radius: 16px;
  --radius-lg: 22px;
  --elev: 0 10px 30px rgba(2,32,71,.08);
  --ring: rgba(126,58,242,.35);
}

:root[data-theme="dark"]{
  --bg: #0B0F16;
  --card: #0E1117;     /* cartão pretão */
  --surface: #0D1016;  /* superfícies igualmente escuras */
  --text: #E6E8EC;
  --muted: #9BA3AF;
  --borderC: #2B313C;
  --elev: 0 10px 28px rgba(0,0,0,.45);
  --ring: rgba(126,58,242,.55);
}

html,body{background:var(--bg);color:var(--text);}
.bg-card{background:var(--card);}
.bg-surface{background:var(--surface);}
.border{border:1px solid var(--borderC);}
.border-border{border-color:var(--borderC);}
.text-muted{color:var(--muted);}
.rounded-xl{border-radius:var(--radius);}
.rounded-2xl{border-radius:var(--radius-lg);}
.shadow-soft{box-shadow:var(--elev);}

/* Pílulas de navegação (sidebar) */
.nav-pill{
  display:flex;align-items:center;justify-content:flex-start;
  height:56px;padding:0 18px;border:1px solid var(--borderC);
  border-radius:999px;background:var(--card);color:var(--text);
  transition:box-shadow .18s ease, transform .12s ease, background .18s ease;
}
:root[data-theme="dark"] .nav-pill{ background:#121722; border-color:#293241; }
.nav-pill:hover{ box-shadow:0 0 0 4px var(--ring); transform:translateY(-1px); }
.nav-pill--active{ background: var(--accent); color:#fff; border-color:transparent; }

/* Cartões padrão */
.card{
  background:var(--card); border:1px solid var(--borderC);
  border-radius:var(--radius); box-shadow:var(--elev);
}

/* Botões + glow */
.btn{ 
  display:inline-flex; align-items:center; justify-content:center;
  gap:8px; height:44px; padding:0 18px; border-radius:999px;
  border:1px solid var(--borderC); background:var(--card); color:var(--text);
  transition: box-shadow .18s ease, transform .12s ease, background .18s ease, border-color .18s;
}
.btn-primary{
  background:var(--accent); color:#fff; border-color:transparent;
}
.btn-outline{
  background:transparent;
}
.btn:hover{ box-shadow:0 0 0 6px var(--ring), 0 8px 20px rgba(0,0,0,.08); transform:translateY(-1px); }
.btn:active{ transform:translateY(0); box-shadow:0 0 0 4px var(--ring); }

/* Inputs simples */
.input{
  height:44px; width:100%; border:1px solid var(--borderC); border-radius:12px;
  background:var(--surface); color:var(--text); padding:0 12px;
}
.input:focus{ outline:none; box-shadow:0 0 0 4px var(--ring); }
CSS

# 2) Helper de sessão (cookies) – usado pelo Topbar/Sidebar
mkdir -p components/lib
cat > components/lib/session.ts <<'TS'
"use client";

export type Role = "admin" | "sponsor";
export type Session = { role?: Role; brand?: string; username?: string };

export function readCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  const escaped = name.replace(/([.$?*|{}()[\]\\/+^])/g, "\\$1");
  const re = new RegExp("(?:^|; )" + escaped + "=([^;]*)");
  const m = document.cookie.match(re);
  return m ? decodeURIComponent(m[1]) : undefined;
}

export function readSession(): Session {
  return {
    role: (readCookie("role") as Role | undefined),
    brand: readCookie("brand") || undefined,
    username: readCookie("username") || undefined,
  };
}
TS

# 3) Topbar – logo maior (sem texto) + logout sólido
mkdir -p components/ui
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { readSession } from "@/components/lib/session";

export default function Topbar(){
  const { role, brand } = readSession();
  const pathname = usePathname();

  const onLogout = async ()=>{
    try{
      await fetch("/api/logout", { method:"POST" });
    }catch{}
    window.location.href = "/login";
  };

  // Logo só quando sponsor
  const showBrand = role === "sponsor" && brand;

  return (
    <header className="sticky top-0 z-30 bg-[var(--bg)]/85 backdrop-blur border-b border-border">
      <div className="mx-auto max-w-screen-2xl flex items-center justify-between gap-3 px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-[var(--card)] grid place-items-center border border-border">
            <span className="text-sm font-semibold">E</span>
          </div>
          <span className="font-semibold">Engage</span>
        </div>

        <div className="flex items-center gap-2">
          {showBrand && (
            <span className="inline-flex items-center h-10 rounded-full border border-border bg-[var(--card)] px-3">
              <Image
                alt={brand!}
                src={`/logos/${brand!.toLowerCase()}.png`}
                width={48} height={48}
                style={{borderRadius:8, display:"block"}}
              />
            </span>
          )}
          <button onClick={onLogout} className="btn btn-outline">Sair</button>
        </div>
      </div>
    </header>
  );
}
TSX

# 4) Sidebar – pílulas claras (light) e escuras (dark), item Settings do sponsor
cat > components/ui/Sidebar.tsx <<'TSX'
"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { readSession } from "@/components/lib/session";

function Item({href, children, active}:{href:string; children:React.ReactNode; active:boolean}){
  return (
    <Link
      href={href}
      className={`nav-pill ${active ? "nav-pill--active" : ""}`}
    >
      {children}
    </Link>
  );
}

export default function Sidebar(){
  const { role, brand } = readSession();
  const pathname = usePathname();
  const isSponsor = role === "sponsor";

  if (isSponsor){
    const base = `/sponsor/${(brand||"acme").toLowerCase()}`;
    const items = [
      { href: `${base}/overview`,   label: "Overview" },
      { href: `${base}/results`,    label: "Resultados" },
      { href: `${base}/financials`, label: "Financeiro" },
      { href: `${base}/events`,     label: "Eventos" },
      { href: `${base}/assets`,     label: "Assets" },
      { href: `${base}/settings`,   label: "Settings" },
    ];
    return (
      <aside className="space-y-3">
        {items.map(i=>(
          <Item key={i.href} href={i.href} active={pathname.startsWith(i.href)}>{i.label}</Item>
        ))}
      </aside>
    );
  }

  // Admin
  const items = [
    { href: "/",           label: "Overview" },
    { href: "/pipeline",   label: "Pipeline" },
    { href: "/projetos",   label: "Projetos" },
    { href: "/settings",   label: "Settings" },
  ];
  return (
    <aside className="space-y-3">
      {items.map(i=>(
        <Item key={i.href} href={i.href} active={pathname === i.href}>{i.label}</Item>
      ))}
    </aside>
  );
}
TSX

# 5) Settings do sponsor (tema Light/Dark/System + campos básicos)
mkdir -p app/sponsor/[brand]/settings
cat > app/sponsor/[brand]/settings/page.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";

type ThemeOpt = "light" | "dark" | "system";

export default function SponsorSettings(){
  const [theme, setTheme] = useState<ThemeOpt>("system");
  const [nome, setNome] = useState("");
  const [cnpj, setCnpj] = useState("");
  const [email, setEmail] = useState("");
  const [fone, setFone] = useState("");

  useEffect(()=>{
    const pref = localStorage.getItem("theme-pref") as ThemeOpt | null;
    setTheme(pref || "system");
  },[]);

  useEffect(()=>{
    const html = document.documentElement;
    if(theme === "system"){
      const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
      html.setAttribute("data-theme", prefersDark ? "dark" : "light");
    }else{
      html.setAttribute("data-theme", theme);
    }
    localStorage.setItem("theme-pref", theme);
  },[theme]);

  return (
    <main className="grid gap-6">
      <section className="card p-5">
        <h2 className="font-semibold mb-3">Aparência</h2>
        <div className="flex gap-2">
          {(["light","dark","system"] as ThemeOpt[]).map(t=>(
            <button
              key={t}
              onClick={()=>setTheme(t)}
              className={`btn ${theme===t?"btn-primary":""}`}
            >
              {t[0].toUpperCase()+t.slice(1)}
            </button>
          ))}
        </div>
      </section>

      <section className="card p-5">
        <h2 className="font-semibold mb-3">Dados da empresa</h2>
        <div className="grid md:grid-cols-2 gap-4">
          <label className="block">
            <div className="text-sm mb-1">Nome</div>
            <input className="input" value={nome} onChange={e=>setNome(e.target.value)} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">CNPJ</div>
            <input className="input" value={cnpj} onChange={e=>setCnpj(e.target.value)} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">E-mail</div>
            <input className="input" value={email} onChange={e=>setEmail(e.target.value)} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">Telefone</div>
            <input className="input" value={fone} onChange={e=>setFone(e.target.value)} />
          </label>
        </div>
      </section>
    </main>
  );
}
TSX

# 6) Login polido (contraste e feedback) – mantém mesma regra de demo
cat > app/login/login-form.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";

type Role = "admin" | "sponsor";

export default function LoginForm(){
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(()=>{ setUsername("admin"); setPassword("123456"); }, []);

  function resolveBrandFromUser(u: string){
    return u.toLowerCase()==="sponsor" ? "heineken" : "acme";
  }

  async function onSubmit(e: React.FormEvent){
    e.preventDefault();
    const ok =
      (role==="admin" && username==="admin" && password==="123456") ||
      (role==="sponsor" && username==="sponsor" && password==="000000");
    if(!ok){ alert("Usuário ou senha inválidos"); return; }

    setLoading(true);
    const brand = role==="sponsor" ? resolveBrandFromUser(username) : undefined;
    const resp = await fetch("/api/auth", {
      method:"POST",
      headers:{ "content-type":"application/json" },
      body: JSON.stringify({ role, brand })
    });
    setLoading(false);
    if(!resp.ok){ alert("Falha ao autenticar"); return; }

    if(role==="sponsor") window.location.href = `/sponsor/${brand}/overview`;
    else window.location.href = `/`;
  }

  const card = "card p-6";

  return (
    <main className="min-h-[calc(100vh-64px)] grid place-items-center px-4">
      <div className="w-full max-w-4xl space-y-6">
        <div className="grid md:grid-cols-2 gap-4">
          <button
            type="button"
            onClick={()=>{ setRole("admin"); setUsername("admin"); setPassword("123456"); }}
            className={`border rounded-2xl p-5 bg-[var(--card)] ${role==="admin"?"outline outline-2 outline-[var(--accent)]":""}`}
          >
            <div className="text-sm text-muted">Perfil</div>
            <div className="mt-1 font-semibold">Interno (Admin)</div>
            <div className="text-sm text-muted mt-1">Acesso completo</div>
          </button>
          <button
            type="button"
            onClick={()=>{ setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}
            className={`border rounded-2xl p-5 bg-[var(--card)] ${role==="sponsor"?"outline outline-2 outline-[var(--accent)]":""}`}
          >
            <div className="text-sm text-muted">Perfil</div>
            <div className="mt-1 font-semibold">Patrocinador</div>
            <div className="text-sm text-muted mt-1">Acesso ao próprio contrato</div>
          </button>
        </div>

        <form onSubmit={onSubmit} className={`${card} space-y-4`}>
          <div className="grid md:grid-cols-2 gap-4">
            <label className="block">
              <div className="text-sm mb-1">Usuário</div>
              <input className="input" value={username} onChange={e=>setUsername(e.target.value)} placeholder={role==="admin"?"admin":"sponsor"} />
            </label>
            <label className="block">
              <div className="text-sm mb-1">Senha</div>
              <input className="input" type="password" value={password} onChange={e=>setPassword(e.target.value)} placeholder={role==="admin"?"123456":"000000"} />
            </label>
          </div>
          <div className="flex gap-2">
            <button className="btn btn-primary px-6" type="submit" disabled={loading}>{loading?"Entrando...":"Entrar"}</button>
            <button
              className="btn"
              type="button"
              onClick={()=> role==="admin" ? (setUsername("admin"), setPassword("123456")) : (setUsername("sponsor"), setPassword("000000"))}
            >
              Preencher exemplo
            </button>
          </div>
        </form>
      </div>
    </main>
  );
}
TSX

# 7) Rebuild
echo "== Build =="
pnpm build

echo
echo "✅ Patch 20 aplicado. Teste rápido:"
echo "  • Admin:    usuario=admin   senha=123456"
echo "  • Sponsor:  usuario=sponsor senha=000000"
