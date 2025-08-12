"use client";
import { useState, useEffect } from "react";
import Button from "@/components/ui/Button";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  // Preenche exemplo pra facilitar demo
  useEffect(() => { setUsername("admin"); setPassword("123456"); }, []);

  function resolveBrandFromUser(u: string): string {
    // Regra simples de demo
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

    const brand = role === "sponsor" ? resolveBrandFromUser(username) : undefined;
    await fetch("/api/auth", {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      body: JSON.stringify({ role, brand }),
    });

    // Redireciona pelo perfil
    if (role === "sponsor") window.location.href = `/sponsor/${brand}/overview`;
    else window.location.href = "/";
  }

  return (
    <div className="space-y-6">
      <div className="grid md:grid-cols-2 gap-4">
        <button
          onClick={() => { setRole("admin"); setUsername("admin"); setPassword("123456"); }}
          className={`rounded-2xl border p-5 text-left bg-card border-border hover:shadow-soft transition ${
            role === "admin" ? "ring-2 ring-[var(--accent)]" : ""
          }`}
        >
          <div className="text-sm text-muted">Perfil</div>
          <div className="mt-1 font-semibold">Interno (Admin)</div>
          <div className="text-sm text-muted mt-1">Acesso a tudo</div>
        </button>

        <button
          onClick={() => { setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}
          className={`rounded-2xl border p-5 text-left bg-card border-border hover:shadow-soft transition ${
            role === "sponsor" ? "ring-2 ring-[var(--accent)]" : ""
          }`}
        >
          <div className="text-sm text-muted">Perfil</div>
          <div className="mt-1 font-semibold">Patrocinador</div>
          <div className="text-sm text-muted mt-1">Acesso ao próprio contrato</div>
        </button>
      </div>

      <form onSubmit={onSubmit} className="rounded-2xl border border-border bg-card p-6 shadow-soft space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <label className="block">
            <div className="text-sm mb-1">Usuário</div>
            <input
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full h-11 rounded-xl border border-border bg-surface px-3"
              placeholder={role === "admin" ? "admin" : "sponsor"}
              autoComplete="username"
            />
          </label>
          <label className="block">
            <div className="text-sm mb-1">Senha</div>
            <input
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full h-11 rounded-xl border border-border bg-surface px-3"
              placeholder={role === "admin" ? "123456" : "000000"}
              type="password"
              autoComplete="current-password"
            />
          </label>
        </div>

        <div className="flex gap-3 pt-2">
          <Button type="submit" size="lg" className="px-6">Entrar</Button>
          <Button type="button" variant="outline" onClick={()=>{
            if (role === "admin") { setUsername("admin"); setPassword("123456"); }
            else { setUsername("sponsor"); setPassword("000000"); }
          }}>Preencher exemplo</Button>
        </div>
      </form>
    </div>
  );
}
