set -euo pipefail

echo "== Patch 18: light menu + logout sólido + login polido =="

# 1) Paleta e pills de navegação (garante contraste bom no LIGHT e DARK)
cat > styles/tokens.css <<'CSS'
:root {
  /* Brand / Accent (roxo) */
  --accent: #7E3AF2;
  --accent-600: #6C2BD9;
  --accent-700: #5B21B6;

  /* Light */
  --bg: #F6F8FB;
  --surface: #FFFFFF;
  --card: #FFFFFF;
  --text: #0B1524;
  --muted: #606B85;
  --borderC: rgba(16,24,40,.14);
  --ring: rgba(126,58,242,.35);

  --radius: 16px;
  --radius-lg: 20px;
  --elev: 0 12px 28px rgba(2,32,71,.08);
}

:root[data-theme="dark"] {
  --bg: #0B0F17;        /* fundo do app */
  --surface: #0E131D;   /* blocos */
  --card: #0E131D;      /* cards */
  --text: #E9EDF5;
  --muted: #99A2B0;
  --borderC: rgba(255,255,255,.10);
  --ring: rgba(126,58,242,.55);
  --elev: 0 16px 36px rgba(0,0,0,.45);
}

html,body{background:var(--bg);color:var(--text)}
.bg-card{background:var(--card)}
.bg-surface{background:var(--surface)}
.text-muted{color:var(--muted)}
.border{border:1px solid var(--borderC)}
.border-border{border-color:var(--borderC)}
.rounded-xl{border-radius:var(--radius)}
.rounded-2xl{border-radius:var(--radius-lg)}
.shadow-soft{box-shadow:var(--elev)}

/* Navegação lateral – pills com contraste seguro nos dois temas */
.navpill{
  display:flex;align-items:center;gap:.625rem;
  height:56px;padding:0 18px;border-radius:9999px;
  border:1px solid var(--borderC); background:color-mix(in srgb, var(--surface) 92%, transparent);
  transition:background .2s ease, box-shadow .2s ease, border-color .2s ease, transform .06s ease;
}
.navpill:hover{ box-shadow:0 0 0 4px var(--ring); border-color:transparent }
.navpill:active{ transform:translateY(1px) }
.navpill--active{
  background:var(--accent); color:#fff; border-color:transparent;
}

/* Chips/Buttons básicos */
.btn{
  display:inline-flex;align-items:center;justify-content:center;gap:.5rem;
  height:44px;padding:0 18px;border-radius:9999px;border:1px solid var(--borderC);
  background:var(--surface); color:var(--text);
  transition:box-shadow .2s ease, transform .06s ease, background .2s ease, border-color .2s ease;
}
.btn:hover{ box-shadow:0 0 0 4px var(--ring) }
.btn:active{ transform:translateY(1px) }
.btn-primary{ background:var(--accent); color:#fff; border-color:transparent }
.btn-outline{ background:transparent }

/* Inputs */
.input{
  height:46px;width:100%;border:1px solid var(--borderC);
  border-radius:14px;background:var(--surface);padding:0 12px;
}

/* Cards */
.card{ background:var(--surface); border:1px solid var(--borderC); border-radius:18px; box-shadow:var(--elev) }
CSS

# 2) Topbar – logout robusto (POST /api/logout + limpeza + redirect)
applypatch() {
  perl -0777 -pe "$1" -i components/ui/Topbar.tsx
}
applypatch 's/async function logout\([\s\S]*?\}\n/async function logout() {\n  try {\n    await fetch(\"\\/api\\/logout\", { method: \"POST\" });\n  } catch {}\n  try { localStorage.removeItem(\"engage_theme\"); } catch {}\n  document.cookie = \"role=; Max-Age=0; path=\\/\";\n  document.cookie = \"brand=; Max-Age=0; path=\\/\";\n  window.location.href = \"\\/login\";\n}\n/g'

# 3) Sidebar – aplica classes .navpill e corrige rota Settings (sponsor)
perl -0777 -pe '
  s/className="[^"]*sidebar-pill[^"]*"/className="navpill"/g;
  s/\bactiveClassName="[^"]*"/ /g;
' -i components/ui/Sidebar.tsx

# 3.1) Garante link de Settings correto para sponsor
perl -0777 -pe '
  s@href=\{`/settings`\}@href={role==="sponsor" ? `/sponsor/${brand??"acme"}/settings` : "/settings"}@g;
' -i components/ui/Sidebar.tsx 2>/dev/null || true

# 4) Login – contraste e layout
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

  function brandFromUser(u: string) { return u.toLowerCase() === "sponsor" ? "heineken" : "acme"; }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    const ok = (role==="admin" && username==="admin" && password==="123456") ||
               (role==="sponsor" && username==="sponsor" && password==="000000");
    if (!ok) { alert("Usuário ou senha inválidos"); return; }

    setLoading(true);
    const brand = role==="sponsor" ? brandFromUser(username) : undefined;
    await fetch("/api/auth", {
      method:"POST",
      headers:{ "content-type":"application/json" },
      body: JSON.stringify({ role, brand })
    }).catch(()=>{});
    setLoading(false);

    if (role==="sponsor") window.location.href = `/sponsor/${brand}/overview`;
    else window.location.href = "/";
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

# 5) Pequena melhoria: botão "Sair" garante type=button
perl -0777 -pe 's/<button([^>]*?)>(\s*?)Sair<\/button>/<button type="button"$1>Sair<\/button>/g' -i components/ui/Topbar.tsx

echo "== Build =="
pnpm build
