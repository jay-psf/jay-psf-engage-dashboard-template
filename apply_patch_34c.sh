set -euo pipefail
echo "== Patch 34c: regrava Login como Client Page válida + corrige RoleSwitch =="

# 1) Regrava a página /login com Client Component + export default
mkdir -p app/login
cat > app/login/page.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";
import Button from "@/components/ui/Button";
import RoleSwitch from "@/components/ui/RoleSwitch";

type Role = "admin" | "sponsor";

export default function LoginPage(){
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(()=>{
    // Prefill sugestivo p/ agilizar testes
    if(role==="admin"){ setUsername("admin"); setPassword("123456"); }
    else { setUsername("sponsor"); setPassword("000000"); }
  },[role]);

  async function handleSubmit(e: React.FormEvent){
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const res = await fetch("/api/auth", {
        method: "POST",
        headers: { "Content-Type":"application/json" },
        body: JSON.stringify({ username, password, role }),
      });
      if(!res.ok){ throw new Error("Falha no login"); }
      // Redireciona por papel (brand do sponsor já é setada pelo /api/auth mock)
      window.location.href = role === "admin" ? "/admin" : "/sponsor/heineken/overview";
    } catch (err:any){
      setError(err?.message || "Erro inesperado");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="min-h-[80vh] grid place-items-center p-6">
      <div className="w-full max-w-md rounded-2xl bg-[var(--card)] border border-[var(--borderC)] p-6 shadow-soft animate-[fadeIn_.3s_ease]">
        <div className="mb-5 text-center">
          <h1 className="text-xl font-semibold">Entrar</h1>
          <p className="text-sm text-[var(--muted)]">Escolha o tipo de acesso e informe suas credenciais.</p>
        </div>

        <div className="mb-4">
          <RoleSwitch value={role} onChange={(r)=>setRole(r as Role)} />
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm mb-1">Usuário</label>
            <input
              className="input"
              value={username}
              onChange={(e)=>setUsername(e.target.value)}
              placeholder={role==="admin" ? "admin" : "sponsor"}
              required
            />
          </div>
          <div>
            <label className="block text-sm mb-1">Senha</label>
            <input
              className="input"
              type="password"
              value={password}
              onChange={(e)=>setPassword(e.target.value)}
              placeholder={role==="admin" ? "123456" : "000000"}
              required
            />
          </div>

          {error && (
            <div className="rounded-xl border border-[var(--borderC)] bg-[var(--surface)] p-3 text-sm">
              {error}
            </div>
          )}

          <div className="flex items-center justify-between pt-1">
            <a href="/forgot-password" className="text-sm text-[var(--accent)] underline">Esqueci minha senha</a>
            <div className="flex gap-3">
              <a href="/" className="btn btn-outline">Cancelar</a>
              <Button type="submit" disabled={loading}>
                {loading ? "Entrando…" : "Entrar"}
              </Button>
            </div>
          </div>
        </form>
      </div>
    </main>
  );
}
TSX

# 2) Corrige o warning do RoleSwitch (deps do useEffect)
if test -f components/ui/RoleSwitch.tsx; then
  # Garante que o efeito notifique quando onChange mudar
  perl -0777 -pe 's/useEffect\(\s*\(\)\s*=>\s*\{\s*if\s*\(onChange\)\s*onChange\(localRole\);\s*\}\s*,\s*\[localRole\]\s*\);/useEffect(() => { if (onChange) onChange(localRole); }, [localRole, onChange]);/gs' -i components/ui/RoleSwitch.tsx || true
fi

echo "== Build =="
pnpm build
