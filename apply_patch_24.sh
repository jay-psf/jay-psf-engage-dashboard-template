set -euo pipefail
echo "== Patch 24: Login com RoleToggle central + ajustes de botões =="

mkdir -p components/ui
cat > components/ui/RoleToggle.tsx <<'TSX'
"use client";
import { useEffect } from "react";

type Props = {
  value: "admin" | "sponsor";
  onChange: (v: "admin" | "sponsor") => void;
};
export default function RoleToggle({ value, onChange }: Props) {
  const isSponsor = value === "sponsor";
  useEffect(()=>{},[value]);

  return (
    <div className="w-full max-w-[380px] mx-auto">
      <div className="relative h-12 rounded-2xl bg-[var(--surface)] border border-[var(--borderC)]">
        <div
          className="absolute top-1 bottom-1 w-[calc(50%-6px)] rounded-xl bg-[var(--card)] shadow-[var(--elev)] transition-transform"
          style={{ transform: `translateX(${isSponsor ? "calc(100% + 12px)" : "12px"})` }}
          aria-hidden
        />
        <div className="relative z-10 grid grid-cols-2 h-full text-sm font-medium">
          <button
            type="button"
            className={`rounded-xl transition-colors ${!isSponsor ? "text-[var(--text)]" : "text-[var(--muted)]"}`}
            onClick={()=>onChange("admin")}
          >
            Admin
          </button>
          <button
            type="button"
            className={`rounded-xl transition-colors ${isSponsor ? "text-[var(--text)]" : "text-[var(--muted)]"}`}
            onClick={()=>onChange("sponsor")}
          >
            Patrocinador
          </button>
        </div>
      </div>
    </div>
  );
}
TSX

# Tela de login usando o RoleToggle
cat > app/login/page.tsx <<'TSX'
"use client";
import { useState } from "react";
import RoleToggle from "@/components/ui/RoleToggle";

export default function LoginPage() {
  const [role, setRole] = useState<"admin"|"sponsor">("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const demo = () => {
    if (role === "admin") { setUsername("admin"); setPassword("123456"); }
    else { setUsername("sponsor"); setPassword("000000"); }
  };

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const r = await fetch("/api/auth", {
        method: "POST",
        headers: { "Content-Type":"application/json"},
        body: JSON.stringify({ role, username, password })
      });
      if (!r.ok) throw new Error("auth");
      window.location.href = role === "admin" ? "/admin" : `/sponsor/${encodeURIComponent("heineken")}/overview`;
    } catch {
      alert("Usuário ou senha inválidos");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[80vh] flex items-center justify-center px-4">
      <div className="w-full max-w-[680px] rounded-2xl bg-[var(--card)] border border-[var(--borderC)] shadow-[var(--elev-strong)] p-8">
        <div className="mb-6 text-center">
          <h1 className="text-2xl font-semibold">Entrar</h1>
          <p className="text-[var(--muted)] mt-1">Escolha o perfil e informe suas credenciais.</p>
        </div>

        <RoleToggle value={role} onChange={setRole} />

        <form onSubmit={submit} className="mt-6 grid gap-4">
          <div className="grid gap-2">
            <label className="text-sm">Usuário</label>
            <input
              value={username}
              onChange={e=>setUsername(e.target.value)}
              className="h-11 rounded-xl bg-[var(--surface)] border border-[var(--borderC)] px-3 outline-none focus:ring-4 focus:ring-[var(--ring)]"
              placeholder={role==="admin" ? "admin" : "sponsor"}
              autoComplete="username"
            />
          </div>
          <div className="grid gap-2">
            <label className="text-sm">Senha</label>
            <input
              type="password"
              value={password}
              onChange={e=>setPassword(e.target.value)}
              className="h-11 rounded-xl bg-[var(--surface)] border border-[var(--borderC)] px-3 outline-none focus:ring-4 focus:ring-[var(--ring)]"
              placeholder="••••••"
              autoComplete="current-password"
            />
          </div>

          <div className="flex gap-3 pt-2">
            <button
              type="submit"
              className="btn"
              disabled={loading}
            >{loading ? "Entrando..." : "Entrar"}</button>
            <button
              type="button"
              className="btn btn-outline"
              onClick={demo}
            >Preencher exemplo</button>
          </div>
        </form>
      </div>
    </div>
  );
}
TSX

echo "== Build =="
pnpm -s build
