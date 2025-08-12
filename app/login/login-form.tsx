"use client";
import { useState } from "react";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [brand, setBrand] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const r = await fetch("/api/auth", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password, brand: role === "sponsor" ? brand : "" }),
      });
      const data = await r.json();
      if (!r.ok) throw new Error(data?.message || "Falha no login");
      window.location.href = data.redirect || "/";
    } catch (err: any) {
      setError(err.message || "Erro inesperado");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="min-h-screen grid place-items-center p-6">
      <div className="w-full max-w-2xl grid gap-6">
        <div className="grid md:grid-cols-2 gap-4">
          <button
            type="button"
            onClick={() => setRole("admin")}
            className={`card p-4 text-left ${role==="admin" ? "ring-2 ring-[var(--ring)]" : ""}`}
          >
            <div className="text-sm text-muted">Perfil</div>
            <div className="font-semibold">Interno (Admin)</div>
            <div className="text-xs text-muted mt-1">Acesso a tudo</div>
          </button>

          <button
            type="button"
            onClick={() => setRole("sponsor")}
            className={`card p-4 text-left ${role==="sponsor" ? "ring-2 ring-[var(--ring)]" : ""}`}
          >
            <div className="text-sm text-muted">Perfil</div>
            <div className="font-semibold">Patrocinador</div>
            <div className="text-xs text-muted mt-1">Acesso ao próprio contrato</div>
          </button>
        </div>

        <form onSubmit={onSubmit} className="card p-5 grid gap-4">
          <div className="grid md:grid-cols-2 gap-3">
            <div>
              <label className="text-sm text-muted">Usuário</label>
              <input className="input" value={username} onChange={e=>setUsername(e.target.value)} placeholder={role==="admin"?"admin":"sponsor"} />
            </div>
            <div>
              <label className="text-sm text-muted">Senha</label>
              <input className="input" type="password" value={password} onChange={e=>setPassword(e.target.value)} placeholder={role==="admin"?"123456":"000000"} />
            </div>
          </div>

          {role === "sponsor" && (
            <div>
              <label className="text-sm text-muted">Marca (brand)</label>
              <input className="input" value={brand} onChange={e=>setBrand(e.target.value)} placeholder="acme" />
            </div>
          )}

          {error && <div className="text-danger text-sm">{error}</div>}

          <div className="flex gap-3">
            <button className="btn-primary" disabled={loading}>{loading?"Entrando...":"Entrar"}</button>
            <button
              type="button"
              onClick={()=>{ setUsername(role==="admin"?"admin":"sponsor"); setPassword(role==="admin"?"123456":"000000"); if(role==="sponsor") setBrand("acme"); }}
              className="px-4 py-2 rounded-lg border"
            >
              Preencher exemplo
            </button>
          </div>
        </form>
      </div>
    </main>
  );
}
