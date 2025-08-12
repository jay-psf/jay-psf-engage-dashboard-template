"use client";
import { useState, useEffect } from "react";
import Button from "@/components/ui/Button";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => { setUsername("admin"); setPassword("123456"); }, []);

  function resolveBrandFromUser(u: string) {
    return u.toLowerCase() === "sponsor" ? "heineken" : "acme";
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();

    const ok =
      (role === "admin" && username === "admin" && password === "123456") ||
      (role === "sponsor" && username === "sponsor" && password === "000000");

    if (!ok) {
      alert("Usuário ou senha inválidos");
      return;
    }

    setLoading(true);
    const brand = role === "sponsor" ? resolveBrandFromUser(username) : undefined;

    // 1) chama API (mantemos por simetria)
    try {
      await fetch("/api/auth", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ role, brand }),
      }).catch(()=>{});
    } catch {}

    // 2) garante cookies também no navegador (mata qualquer problema de set-cookie)
    // Obs: SameSite=Lax e path=/ são suficientes para nosso fluxo
    const attrs = "path=/; samesite=lax";
    document.cookie = `role=${role}; ${attrs}`;
    if (brand) document.cookie = `brand=${brand}; ${attrs}`;

    // 3) tema (sponsor = dark)
    const html = document.documentElement;
    if (role === "sponsor") html.setAttribute("data-theme", "dark");
    else html.removeAttribute("data-theme");

    setLoading(false);

    // 4) navega
    if (role === "sponsor") window.location.href = `/sponsor/${brand}/overview`;
    else window.location.href = "/";
  }

  return (
    <main className="min-h-[calc(100vh-64px)] grid place-items-center px-4">
      <div className="w-full max-w-4xl space-y-6">
        <div className="grid md:grid-cols-2 gap-4">
          <button
            type="button"
            onClick={() => { setRole("admin"); setUsername("admin"); setPassword("123456"); }}
            className={`rounded-2xl border p-5 text-left bg-card shadow-soft transition ${
              role === "admin" ? "ring-2 ring-accent" : "hover:shadow-lg"
            }`}
          >
            <div className="text-sm text-muted">Perfil</div>
            <div className="mt-1 font-semibold">Interno (Admin)</div>
            <div className="text-sm text-muted mt-1">Acesso completo</div>
          </button>

          <button
            type="button"
            onClick={() => { setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}
            className={`rounded-2xl border p-5 text-left bg-card shadow-soft transition ${
              role === "sponsor" ? "ring-2 ring-accent" : "hover:shadow-lg"
            }`}
          >
            <div className="text-sm text-muted">Perfil</div>
            <div className="mt-1 font-semibold">Patrocinador</div>
            <div className="text-sm text-muted mt-1">Acesso ao próprio contrato</div>
          </button>
        </div>

        <form onSubmit={onSubmit} className="rounded-2xl border bg-card p-6 shadow-soft space-y-4">
          <div className="grid md:grid-cols-2 gap-4">
            <label className="block">
              <div className="text-sm mb-1">Usuário</div>
              <input
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="w-full h-12 rounded-xl border bg-surface px-3 outline-none focus:ring-2 focus:ring-accent transition"
                placeholder={role === "admin" ? "admin" : "sponsor"}
              />
            </label>
            <label className="block">
              <div className="text-sm mb-1">Senha</div>
              <input
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full h-12 rounded-xl border bg-surface px-3 outline-none focus:ring-2 focus:ring-accent transition"
                placeholder={role === "admin" ? "123456" : "000000"}
                type="password"
              />
            </label>
          </div>

          <div className="flex gap-3 pt-2">
            <Button type="submit" size="lg" className="px-7">
              {loading ? "Entrando..." : "Entrar"}
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={()=>{
                if (role === "admin") { setUsername("admin"); setPassword("123456"); }
                else { setUsername("sponsor"); setPassword("000000"); }
              }}
            >
              Preencher exemplo
            </Button>
          </div>
        </form>
      </div>
    </main>
  );
}
