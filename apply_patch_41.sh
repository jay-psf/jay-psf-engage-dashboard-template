set -euo pipefail
echo "== Patch 41: Login deslizante polido + RoleSwitch fix =="

# 1) RoleSwitch: corrige dependências do hook
mkdir -p components/ui
if [ -f components/ui/RoleSwitch.tsx ]; then
  awk 'BEGIN{fixed=0}
  /export default function RoleSwitch/ {print; print "  const onChangeCb = useCallback((r: \"admin\"|\"sponsor\") => onChange? onChange(r):void 0, [onChange])"; next}
  /useEffect\(.*onChange/ {print "  useEffect(() => { onChangeCb(localRole); }, [localRole, onChangeCb])"; getline; fixed=1; next}
  {print}
  END{if(!fixed){}}
  ' components/ui/RoleSwitch.tsx > components/ui/RoleSwitch.tmp || true
  mv components/ui/RoleSwitch.tmp components/ui/RoleSwitch.tsx
  sed -i '1i "use client";\nimport { useCallback } from "react";' components/ui/RoleSwitch.tsx
fi

# 2) Login page: segmented control + layout centralizado
mkdir -p app/login
cat > app/login/page.tsx <<'TSX'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Button from "@/components/ui/Button";

export default function LoginPage(){
  const [role, setRole] = useState<"admin"|"sponsor">("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading,  setLoading]  = useState(false);
  const router = useRouter();

  async function onSubmit(e: React.FormEvent){
    e.preventDefault();
    setLoading(true);
    try{
      const res = await fetch("/api/auth",{ method:"POST", headers:{ "Content-Type":"application/json" }, body: JSON.stringify({ role, username, password }) });
      if(!res.ok) throw new Error("auth");
      document.cookie = `role=${role}; path=/`;
      if(role==="admin") router.push("/admin");
      else {
        const brand = (username?.toLowerCase() || "heineken");
        document.cookie = `brand=${brand}; path=/`;
        router.push(`/sponsor/${brand}/overview`);
      }
    }finally{ setLoading(false); }
  }

  const preset = ()=> {
    if(role==="admin"){ setUsername("admin"); setPassword("123456"); }
    else { setUsername("sponsor"); setPassword("000000"); }
  };

  return (
    <div style={{minHeight:"calc(100vh - 64px)", display:"grid", placeItems:"center", padding:"40px 16px"}}>
      <div className="card" style={{width:"100%",maxWidth:520, padding:24}}>
        <h1 className="h2" style={{marginBottom:12}}>Entrar</h1>
        <p className="subtle" style={{marginBottom:16}}>Selecione o perfil e informe suas credenciais.</p>

        {/* Segmented control */}
        <div role="tablist" aria-label="Selecionar perfil" className="surface" style={{display:"flex",borderRadius:14,overflow:"hidden"}}>
          {(["admin","sponsor"] as const).map(opt=>{
            const active = role===opt;
            return (
              <button key={opt} role="tab" aria-selected={active}
                onClick={()=>setRole(opt)}
                className="focus-ring"
                style={{
                  flex:1, padding:"10px 14px",
                  background: active ? "var(--accent)" : "transparent",
                  color: active ? "white" : "var(--text)",
                  border:"none"
                }}>
                {opt==="admin" ? "Interno" : "Patrocinador"}
              </button>
            );
          })}
        </div>

        <form onSubmit={onSubmit} style={{marginTop:16, display:"grid", gap:12}}>
          <label className="subtle">Usuário</label>
          <input className="input" value={username} onChange={e=>setUsername(e.target.value)} placeholder={role==="admin"?"admin":"sponsor"} />

          <label className="subtle">Senha</label>
          <input className="input" type="password" value={password} onChange={e=>setPassword(e.target.value)} placeholder="••••••" />

          <div style={{display:"flex", gap:12, marginTop:8}}>
            <Button type="submit">{loading ? "Entrando..." : "Entrar"}</Button>
            <Button type="button" variant="outline" onClick={preset}>Preencher</Button>
            <a href="/forgot-password" className="subtle" style={{alignSelf:"center"}}>Esqueci minha senha</a>
          </div>
        </form>
      </div>
    </div>
  );
}
TSX

echo "== Build =="
pnpm build
