"use client";
import { useSearchParams, useRouter } from "next/navigation";
import { useState } from "react";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const params = useSearchParams();
  const router = useRouter();
  const err = params.get("err");
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    const res = await fetch("/api/auth", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password }),
    });
    if (!res.ok) {
      router.push("/login?err=1");
      return;
    }
    const data = await res.json(); // { role, brand }
    // redireciona conforme o papel
    if (data.role === "sponsor" && data.brand) {
      router.push(`/sponsor/${data.brand}/overview`);
    } else {
      router.push("/");
    }
  }

  return (
    <main className="min-h-[75vh] grid place-items-center px-4">
      <div className="grid md:grid-cols-2 gap-4 w-full max-w-5xl">
        <section
          onClick={() => setRole("admin")}
          className={`cursor-pointer rounded-2xl border p-5 ${role==="admin"?"ring-2":""}`}
          style={{background:"var(--panel)",borderColor:"var(--border)",boxShadow:"0 8px 24px rgba(0,0,0,.12)"}}
        >
          <div className="text-sm" style={{color:"var(--muted)"}}>Perfil</div>
          <div className="text-lg font-semibold mt-1">Interno (Admin)</div>
          <div className="text-sm mt-2" style={{color:"var(--muted)"}}>Acesso a tudo</div>
        </section>

        <section
          onClick={() => setRole("sponsor")}
          className={`cursor-pointer rounded-2xl border p-5 ${role==="sponsor"?"ring-2":""}`}
          style={{background:"var(--panel-2)",borderColor:"var(--border)",boxShadow:"0 8px 24px rgba(0,0,0,.12)"}}
        >
          <div className="text-sm" style={{color:"var(--muted)"}}>Perfil</div>
          <div className="text-lg font-semibold mt-1">Patrocinador</div>
          <div className="text-sm mt-2" style={{color:"var(--muted)"}}>Acesso ao próprio contrato</div>
        </section>
      </div>

      <form onSubmit={onSubmit} className="w-full max-w-5xl mt-6 rounded-2xl border p-6"
        style={{background:"var(--panel)",borderColor:"var(--border)"}}>
        {err && (
          <div className="mb-4 rounded-xl px-3 py-2 text-sm" style={{background:"#2d1b1b",color:"#fecaca",border:"1px solid #7f1d1d"}}>
            Usuário ou senha inválidos.
          </div>
        )}
        <div className="grid md:grid-cols-2 gap-4">
          <div>
            <label className="text-sm block mb-2" style={{color:"var(--muted)"}}>Usuário</label>
            <input
              value={username}
              onChange={(e)=>setUsername(e.target.value)}
              placeholder={role==="sponsor"?"sponsor":"admin"}
              className="w-full rounded-xl px-3 py-2 outline-none"
              style={{background:"transparent",border:"1px solid var(--border)",color:"var(--text)"}}
            />
          </div>
          <div>
            <label className="text-sm block mb-2" style={{color:"var(--muted)"}}>Senha</label>
            <input
              type="password"
              value={password}
              onChange={(e)=>setPassword(e.target.value)}
              placeholder={role==="sponsor"?"000000":"123456"}
              className="w-full rounded-xl px-3 py-2 outline-none"
              style={{background:"transparent",border:"1px solid var(--border)",color:"var(--text)"}}
            />
          </div>
        </div>

        <div className="mt-5 flex items-center gap-3">
          <button
            type="submit"
            className="px-5 py-2 rounded-2xl font-semibold shadow"
            style={{background:"var(--brand-accent)",color:"var(--brand-contrast)",boxShadow:"0 8px 24px rgba(0,0,0,.18)"}}
          >
            Entrar
          </button>
          <button
            type="button"
            onClick={()=>{ setUsername(role==="sponsor"?"sponsor":"admin"); setPassword(role==="sponsor"?"000000":"123456"); }}
            className="px-4 py-2 rounded-2xl border"
            style={{borderColor:"var(--border)",color:"var(--text)"}}
          >
            Preencher exemplo
          </button>
        </div>
      </form>
    </main>
  );
}
