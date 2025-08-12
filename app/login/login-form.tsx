"use client";
import { useState, useEffect } from "react";

type Role = "admin" | "sponsor";

export default function LoginForm(){
  const [role,setRole] = useState<Role>("admin");
  const [username,setUsername] = useState("");
  const [password,setPassword] = useState("");
  const [loading,setLoading] = useState(false);

  useEffect(()=>{ setUsername("admin"); setPassword("123456"); },[]);

  const resolveBrand=(u:string)=> u.toLowerCase()==="sponsor" ? "heineken" : "acme";

  async function onSubmit(e:React.FormEvent){
    e.preventDefault();
    const ok =
      (role==="admin" && username==="admin" && password==="123456") ||
      (role==="sponsor" && username==="sponsor" && password==="000000");
    if(!ok){ alert("Usuário ou senha inválidos"); return; }

    setLoading(true);
    const brand = role==="sponsor" ? resolveBrand(username) : undefined;
    const r = await fetch("/api/auth", {
      method:"POST",
      headers:{ "content-type":"application/json" },
      body: JSON.stringify({ role, brand })
    });
    setLoading(false);
    if(!r.ok){ alert("Falha ao autenticar"); return; }

    // grava username para avatar
    document.cookie = `username=${encodeURIComponent(username)}; path=/`;

    if(role==="sponsor") window.location.href = `/sponsor/${brand}/overview`;
    else window.location.href = "/";
  }

  return (
    <section className="min-h-[calc(100vh-64px)] grid place-items-center">
      <div className="w-full max-w-3xl space-y-6">
        <div className="grid md:grid-cols-2 gap-4">
          <button type="button"
            onClick={()=>{ setRole("admin"); setUsername("admin"); setPassword("123456"); }}
            className={`rounded-2xl border p-5 text-left bg-card border-border shadow-soft ${role==="admin"?"ring-2 ring-[var(--ring)]":""}`}>
            <div className="text-sm text-muted">Perfil</div>
            <div className="mt-1 font-semibold">Interno (Admin)</div>
            <div className="text-sm text-muted mt-1">Acesso a tudo</div>
          </button>
          <button type="button"
            onClick={()=>{ setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}
            className={`rounded-2xl border p-5 text-left bg-card border-border shadow-soft ${role==="sponsor"?"ring-2 ring-[var(--ring)]":""}`}>
            <div className="text-sm text-muted">Perfil</div>
            <div className="mt-1 font-semibold">Patrocinador</div>
            <div className="text-sm text-muted mt-1">Acesso ao próprio contrato</div>
          </button>
        </div>

        <form onSubmit={onSubmit} className="rounded-2xl border border-border bg-card p-6 shadow-soft space-y-4">
          <div className="grid md:grid-cols-2 gap-4">
            <label className="block">
              <div className="text-sm mb-1">Usuário</div>
              <input className="input" value={username} onChange={e=>setUsername(e.target.value)}
                placeholder={role==="admin"?"admin":"sponsor"} />
            </label>
            <label className="block">
              <div className="text-sm mb-1">Senha</div>
              <input className="input" type="password" value={password} onChange={e=>setPassword(e.target.value)}
                placeholder={role==="admin"?"123456":"000000"} />
            </label>
          </div>

          <div className="flex gap-3 pt-1">
            <button type="submit" className="btn min-w-28">{loading?"Entrando...":"Entrar"}</button>
            <button type="button" className="btn btn-outline"
              onClick={()=>{ if(role==="admin"){setUsername("admin");setPassword("123456");}
                             else {setUsername("sponsor");setPassword("000000");}}}>
              Preencher exemplo
            </button>
          </div>
        </form>
      </div>
    </section>
  );
}
