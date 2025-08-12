"use client";
import { useEffect, useState } from "react";

type Role = "admin" | "sponsor";

export default function LoginForm(){
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(()=>{ setUsername("admin"); setPassword("123456"); }, []);

  function resolveBrandFromUser(u: string){
    return u.toLowerCase()==="sponsor" ? "heineken" : "acme";
  }

  async function onSubmit(e: React.FormEvent){
    e.preventDefault();
    const ok =
      (role==="admin" && username==="admin" && password==="123456") ||
      (role==="sponsor" && username==="sponsor" && password==="000000");
    if(!ok){ alert("Usuário ou senha inválidos"); return; }

    setLoading(true);
    const brand = role==="sponsor" ? resolveBrandFromUser(username) : undefined;
    const resp = await fetch("/api/auth", {
      method:"POST",
      headers:{ "content-type":"application/json" },
      body: JSON.stringify({ role, brand })
    });
    setLoading(false);
    if(!resp.ok){ alert("Falha ao autenticar"); return; }

    if(role==="sponsor") window.location.href = `/sponsor/${brand}/overview`;
    else window.location.href = `/`;
  }

  const card = "card p-6";

  return (
    <main className="min-h-[calc(100vh-64px)] grid place-items-center px-4">
      <div className="w-full max-w-4xl space-y-6">
        <div className="grid md:grid-cols-2 gap-4">
          <button
            type="button"
            onClick={()=>{ setRole("admin"); setUsername("admin"); setPassword("123456"); }}
            className={`border rounded-2xl p-5 bg-[var(--card)] ${role==="admin"?"outline outline-2 outline-[var(--accent)]":""}`}
          >
            <div className="text-sm text-muted">Perfil</div>
            <div className="mt-1 font-semibold">Interno (Admin)</div>
            <div className="text-sm text-muted mt-1">Acesso completo</div>
          </button>
          <button
            type="button"
            onClick={()=>{ setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}
            className={`border rounded-2xl p-5 bg-[var(--card)] ${role==="sponsor"?"outline outline-2 outline-[var(--accent)]":""}`}
          >
            <div className="text-sm text-muted">Perfil</div>
            <div className="mt-1 font-semibold">Patrocinador</div>
            <div className="text-sm text-muted mt-1">Acesso ao próprio contrato</div>
          </button>
        </div>

        <form onSubmit={onSubmit} className={`${card} space-y-4`}>
          <div className="grid md:grid-cols-2 gap-4">
            <label className="block">
              <div className="text-sm mb-1">Usuário</div>
              <input className="input" value={username} onChange={e=>setUsername(e.target.value)} placeholder={role==="admin"?"admin":"sponsor"} />
            </label>
            <label className="block">
              <div className="text-sm mb-1">Senha</div>
              <input className="input" type="password" value={password} onChange={e=>setPassword(e.target.value)} placeholder={role==="admin"?"123456":"000000"} />
            </label>
          </div>
          <div className="flex gap-2">
            <button className="btn btn-primary px-6" type="submit" disabled={loading}>{loading?"Entrando...":"Entrar"}</button>
            <button
              className="btn"
              type="button"
              onClick={()=> role==="admin" ? (setUsername("admin"), setPassword("123456")) : (setUsername("sponsor"), setPassword("000000"))}
            >
              Preencher exemplo
            </button>
          </div>
        </form>
      </div>
    </main>
  );
}
