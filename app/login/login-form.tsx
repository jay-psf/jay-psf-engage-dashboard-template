"use client";
import { useState } from "react";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    // Patrocinador -> atribui brand automaticamente (ajustaremos quando vier do backend)
    const brand = role === "sponsor" ? "heineken" : "";
    const res = await fetch("/api/auth", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password, role, brand }),
    });
    if (res.ok) {
      // redireciona pelo próprio backend via 302; como fallback:
      window.location.href = role === "sponsor" ? `/sponsor/${brand}/overview` : "/";
    } else {
      alert("Login inválido");
    }
  }

  function fillExample() {
    if (role === "admin") {
      setUsername("admin");
      setPassword("123456");
    } else {
      setUsername("sponsor");
      setPassword("000000");
    }
  }

  const card =
    "rounded-2xl border p-5 bg-entourage-surface-light shadow-soft hover:shadow dark:bg-entourage-surface-dark dark:border-entourage-line-dark";

  return (
    <main className="min-h-[80vh] flex items-start md:items-center justify-center">
      <div className="w-full max-w-5xl p-4 space-y-6">
        <div className="grid md:grid-cols-2 gap-4">
          <button
            type="button"
            onClick={() => setRole("admin")}
            className={`${card} text-left ${role === "admin" ? "ring-2 ring-entourage-primary" : ""}`}
          >
            <div className="text-sm opacity-70">Perfil</div>
            <div className="font-semibold mt-1">Interno (Admin)</div>
            <div className="text-sm opacity-70">Acesso a tudo</div>
          </button>

          <button
            type="button"
            onClick={() => setRole("sponsor")}
            className={`${card} text-left ${role === "sponsor" ? "ring-2 ring-entourage-primary" : ""}`}
          >
            <div className="text-sm opacity-70">Perfil</div>
            <div className="font-semibold mt-1">Patrocinador</div>
            <div className="text-sm opacity-70">Acesso ao próprio contrato</div>
          </button>
        </div>

        <form onSubmit={onSubmit} className={`${card} space-y-4`}>
          <div className="grid md:grid-cols-2 gap-4">
            <label className="block">
              <div className="text-sm opacity-70 mb-1">Usuário</div>
              <input
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder={role === "admin" ? "admin" : "sponsor"}
                className="w-full rounded-xl2 border px-3 py-3 bg-white/90 dark:bg-entourage-bg-dark/50 border-entourage-line-light dark:border-entourage-line-dark outline-none"
              />
            </label>

            <label className="block">
              <div className="text-sm opacity-70 mb-1">Senha</div>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder={role === "admin" ? "123456" : "000000"}
                className="w-full rounded-xl2 border px-3 py-3 bg-white/90 dark:bg-entourage-bg-dark/50 border-entourage-line-light dark:border-entourage-line-dark outline-none"
              />
            </label>
          </div>

          <div className="flex gap-3 pt-2">
            <button
              type="submit"
              className="inline-flex items-center justify-center rounded-pill px-5 py-2.5 bg-entourage-primary text-white font-semibold shadow-soft hover:shadow focus:outline-none active:translate-y-[1px] transition"
            >
              Entrar
            </button>
            <button
              type="button"
              onClick={fillExample}
              className="rounded-pill border px-4 py-2.5 border-entourage-line-light dark:border-entourage-line-dark"
            >
              Preencher exemplo
            </button>
          </div>
        </form>
      </div>
    </main>
  );
}
