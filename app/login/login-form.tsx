"use client";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");
  const router = useRouter();

  useEffect(() => {
    // preencher exemplo rápido
    setUsername(role === "admin" ? "admin" : "sponsor");
    setPassword(role === "admin" ? "123456" : "000000");
  }, [role]);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setErr("");
    try {
      const res = await fetch("/api/auth", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
      });
      if (!res.ok) throw new Error("Usuário ou senha inválidos");
      const data = await res.json();
      // redireciona por papel
      if (data.role === "sponsor") {
        router.push(`/sponsor/${data.brand || "heineken"}/overview`);
      } else {
        router.push("/");
      }
    } catch (e: any) {
      setErr(e.message || "Erro ao entrar");
    } finally {
      setLoading(false);
    }
  }

  const Card = ({
    active,
    title,
    desc,
    onClick,
  }: {
    active: boolean;
    title: string;
    desc: string;
    onClick: () => void;
  }) => (
    <button
      type="button"
      onClick={onClick}
      className={`card block text-left w-full ${active ? "ring-2 ring-[var(--brand-accent)]" : ""}`}
    >
      <div className="text-sm" style={{ color: "var(--muted)" }}>Perfil</div>
      <div className="text-lg font-semibold">{title}</div>
      <div className="text-sm mt-1" style={{ color: "var(--muted)" }}>{desc}</div>
    </button>
  );

  return (
    <div className="max-w-5xl mx-auto grid gap-6">
      <div className="grid md:grid-cols-2 gap-6">
        <Card
          active={role === "admin"}
          title="Interno (Admin)"
          desc="Acesso a tudo"
          onClick={() => setRole("admin")}
        />
        <Card
          active={role === "sponsor"}
          title="Patrocinador"
          desc="Acesso ao próprio contrato"
          onClick={() => setRole("sponsor")}
        />
      </div>

      <form onSubmit={onSubmit} className="card">
        <div className="grid md:grid-cols-2 gap-4">
          <label className="w-full">
            <div className="label">Usuário</div>
            <input
              className="input"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder={role === "admin" ? "admin" : "sponsor"}
              autoComplete="username"
            />
          </label>

          <label className="w-full">
            <div className="label">Senha</div>
            <input
              className="input"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder={role === "admin" ? "123456" : "000000"}
              autoComplete="current-password"
            />
          </label>
        </div>

        {err && <div className="mt-3 text-sm" style={{ color: "salmon" }}>{err}</div>}

        <div className="mt-5 flex items-center gap-3">
          <button
            type="submit"
            disabled={loading}
            className="btn-primary"
          >
            {loading ? "Entrando..." : "Entrar"}
          </button>

          <button
            type="button"
            className="btn-ghost"
            onClick={() => {
              setUsername(role === "admin" ? "admin" : "sponsor");
              setPassword(role === "admin" ? "123456" : "000000");
            }}
          >
            Preencher exemplo
          </button>
        </div>
      </form>
    </div>
  );
}
