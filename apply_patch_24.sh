set -euo pipefail
echo "== Patch 24: Login com toggle + glow luminescente sutil =="

# 1) Tokens/estilos: halo gradiente sutil e utilitários
apply_tokens() {
cat > styles/tokens.css <<'CSS'
:root{
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;

  /* Light */
  --bg:#F6F8FB; --card:#FFFFFF; --surface:#F2F4F9;
  --text:#0B1524; --muted:#667085; --borderC:rgba(16,24,40,.12);

  /* Dark */
  --bg-dark:#0B1220; --card-dark:#0F1627; --surface-dark:#0C1322;
  --text-dark:#E6E8EC; --muted-dark:#9BA3AF; --borderC-dark:rgba(255,255,255,.10);

  /* Sombras/halos */
  --elev:0 10px 30px rgba(2,32,71,.08);
  --elev-dark:0 14px 36px rgba(0,0,0,.35);

  /* Lúmen (glow sutil) */
  --lumen-a: rgba(126,58,242,.28);  /* roxo suave */
  --lumen-b: rgba(126,58,242,.10);  /* dissipado */
  --lumen-c: rgba(255,255,255,.06); /* brilho frio */
  --ring: rgba(126,58,242,.25);
}

/* Dark theme bridge */
:root[data-theme="dark"]{
  --bg:var(--bg-dark);
  --card:var(--card-dark);
  --surface:var(--surface-dark);
  --text:var(--text-dark);
  --muted:var(--muted-dark);
  --borderC:var(--borderC-dark);
}

/* Fundo com leve gradiente para profundidade */
html,body{
  background: var(--bg);
  color: var(--text);
  min-height:100%;
  background-image:
    radial-gradient(900px 500px at 12% -10%, rgba(126,58,242,.045), transparent 46%),
    radial-gradient(900px 500px at 88% -16%, rgba(126,58,242,.035), transparent 52%);
  background-attachment: fixed;
}

/* Lúmen: pseudo-elemento com gradiente radial, suave e responsivo */
.lumen {
  position: relative;
  isolation: isolate;
}
.lumen::after{
  content:"";
  position:absolute; inset:-6px;
  border-radius:inherit;
  z-index:-1;
  opacity:.0;
  transition:opacity .25s ease, filter .25s ease, transform .25s ease;
  background:
    radial-gradient(140% 100% at 30% 0% , var(--lumen-a), transparent 55%),
    radial-gradient(160% 120% at 80% -10%, var(--lumen-b), transparent 55%),
    radial-gradient(140% 120% at 50% -20%, var(--lumen-c), transparent 60%);
  filter: blur(10px);
}
.lumen:hover::after{ opacity:.65; filter: blur(12px); }
.lumen:focus-visible::after{ opacity:.8; filter: blur(14px); }

/* Botões base (mantendo classes existentes do projeto) */
.btn{ border-radius:14px; border:1px solid var(--borderC); transition:all .18s ease; }
.btn-primary{ background:var(--accent); color:white; }
.btn-outline{ background:transparent; color:var(--text); }
.btn:hover{ transform: translateY(-1px); }
.btn:active{ transform: translateY(0); }

/* Caixas/pills */
.pill { border-radius:14px; border:1px solid var(--borderC); background:var(--surface); }
.card { border-radius:18px; border:1px solid var(--borderC); background:var(--card); box-shadow: var(--elev); }
CSS
}
apply_tokens

# 2) RoleSwitch (toggle deslizante admin/sponsor)
mkdir -p components/ui
cat > components/ui/RoleSwitch.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";
import clsx from "clsx";

type Props = {
  value?: "admin" | "sponsor";
  onChange?: (v:"admin"|"sponsor") => void;
};

export default function RoleSwitch({ value, onChange }: Props){
  const [role, setRole] = useState<"admin"|"sponsor">(value ?? "admin");
  useEffect(()=>{ onChange?.(role); },[role]);

  return (
    <div className={clsx(
      "pill lumen w-[360px] h-14 p-1 flex items-center gap-1",
      "bg-[var(--surface)]"
    )}>
      {(["admin","sponsor"] as const).map((k)=>(
        <button
          key={k}
          type="button"
          onClick={()=>setRole(k)}
          className={clsx(
            "flex-1 h-full rounded-[12px] transition-all",
            role===k ? "bg-[var(--card)] text-[var(--text)] shadow"
                     : "text-[var(--muted)]"
          )}
        >
          <div className="h-full grid place-items-center text-sm font-medium">
            {k==="admin" ? "Interno (Admin)" : "Patrocinador"}
          </div>
        </button>
      ))}
      <style jsx>{`
        .shadow{
          box-shadow:
            0 1px 0 rgba(0,0,0,.06),
            inset 0 0 0 1px var(--borderC);
        }
      `}</style>
    </div>
  );
}
TSX

# 3) Login: centralizado, com toggle e CTA com glow sutil
cat > app/login/page.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";
import RoleSwitch from "@/components/ui/RoleSwitch";
import Button from "@/components/ui/Button";

export default function LoginPage(){
  const [role, setRole] = useState<"admin"|"sponsor">("admin");
  const [username, setUsername] = useState("admin");
  const [password, setPassword] = useState("123456");
  const [loading, setLoading] = useState(false);

  useEffect(()=>{
    if(role==="admin"){ setUsername("admin"); setPassword("123456"); }
    else { setUsername("sponsor"); setPassword("000000"); }
  },[role]);

  async function submit(e:React.FormEvent){
    e.preventDefault(); setLoading(true);
    try{
      const r = await fetch("/api/auth",{ method:"POST", headers:{ "Content-Type":"application/json" }, body: JSON.stringify({ username, password, role })});
      if(r.ok){
        if(role==="admin") window.location.href="/admin";
        else window.location.href="/sponsor/heineken/overview";
      } else {
        alert("Usuário ou senha inválidos.");
      }
    } finally{ setLoading(false); }
  }

  return (
    <div className="min-h-[calc(100vh-40px)] grid place-items-center px-4">
      <div className="card w-full max-w-xl p-8">
        <div className="flex flex-col items-center gap-6">
          <h1 className="text-2xl font-semibold">Entrar</h1>
          <RoleSwitch value={role} onChange={setRole} />
          <form onSubmit={submit} className="w-full mt-4 space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm mb-1 text-[var(--muted)]">Usuário</label>
                <input
                  value={username} onChange={e=>setUsername(e.target.value)}
                  className="pill w-full h-11 px-3 bg-[var(--surface)]"
                  autoComplete="username"
                />
              </div>
              <div>
                <label className="block text-sm mb-1 text-[var(--muted)]">Senha</label>
                <input
                  type="password"
                  value={password} onChange={e=>setPassword(e.target.value)}
                  className="pill w-full h-11 px-3 bg-[var(--surface)]"
                  autoComplete="current-password"
                />
              </div>
            </div>
            <div className="pt-2 flex gap-3 justify-center">
              <Button type="submit" size="lg" className="lumen">
                {loading ? "Entrando..." : "Entrar"}
              </Button>
              <Button type="button" variant="outline"
                onClick={()=>{ if(role==="admin"){ setUsername("admin"); setPassword("123456"); } else { setUsername("sponsor"); setPassword("000000"); }}}>
                Preencher exemplo
              </Button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
TSX

# 4) Button: mantém sizes e aplica classe .lumen opcional
cat > components/ui/Button.tsx <<'TSX'
"use client";
import clsx from "clsx";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "outline";
  size?: "sm" | "md" | "lg";
};

export default function Button({ variant="primary", size="md", className, ...rest }: Props){
  const base = "btn";
  const v = variant === "primary" ? "btn-primary" : "btn-outline";
  const s =
    size === "sm" ? "h-9 px-3 text-sm" :
    size === "lg" ? "h-12 px-6 text-base" :
    "h-10 px-4";
  return <button {...rest} className={clsx(base, v, s, className)} />;
}
TSX

echo "== Build =="
pnpm build
echo "== Patch 24 aplicado com sucesso =="
