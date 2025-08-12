"use client";
import { useState, useEffect } from "react";
import Button from "@/components/ui/Button";

type Role = "admin" | "sponsor";

export default function Page(){
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(()=>{ setUsername("admin"); setPassword("123456"); },[]);

  function brandFromUser(u:string){ return u.toLowerCase()==="sponsor" ? "heineken" : "acme"; }

  async function onSubmit(e:React.FormEvent){
    e.preventDefault();
    const ok =
      (role==="admin" && username==="admin" && password==="123456") ||
      (role==="sponsor" && username==="sponsor" && password==="000000");
    if(!ok){ alert("Usuário ou senha inválidos"); return; }

    setLoading(true);
    const brand = role==="sponsor" ? brandFromUser(username) : undefined;
    const resp = await fetch("/api/auth", {
      method:"POST",
      headers:{ "content-type":"application/json" },
      body: JSON.stringify({ role, brand })
    });
    setLoading(false);
    if(!resp.ok){ alert("Falha ao autenticar"); return; }

    if(role==="sponsor") window.location.href = `/sponsor/${brand}/overview`;
    else window.location.href = "/";
  }

  return (
    <main className="w-full max-w-4xl">
      <div className="grid md:grid-cols-2 gap-4 mb-6">
        <button type="button" onClick={()=>{ setRole("admin"); setUsername("admin"); setPassword("123456"); }}
          className={`text-left rounded-2xl border px-5 py-4 bg-card hover:shadow-soft transition ${role==="admin"?"ring-2 ring-[var(--accent)]":""}`}>
          <div className="text-sm text-muted">Perfil</div>
          <div className="mt-1 font-semibold">Interno (Admin)</div>
          <div className="text-sm text-muted mt-1">Acesso completo</div>
        </button>

        <button type="button" onClick={()=>{ setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}
          className={`text-left rounded-2xl border px-5 py-4 bg-card hover:shadow-soft transition ${role==="sponsor"?"ring-2 ring-[var(--accent)]":""}`}>
          <div className="text-sm text-muted">Perfil</div>
          <div className="mt-1 font-semibold">Patrocinador</div>
          <div className="text-sm text-muted mt-1">Acesso ao próprio contrato</div>
        </button>
      </div>

      <form onSubmit={onSubmit} className="card p-6 shadow-soft space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <label className="block">
            <div className="text-sm mb-1">Usuário</div>
            <input className="input" value={username} onChange={(e)=>setUsername(e.target.value)}
              placeholder={role==="admin"?"admin":"sponsor"} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">Senha</div>
            <input className="input" type="password" value={password} onChange={(e)=>setPassword(e.target.value)}
              placeholder={role==="admin"?"123456":"000000"} />
          </label>
        </div>

        <div className="flex gap-3 pt-2">
          <Button type="submit" size="lg">{loading ? "Entrando..." : "Entrar"}</Button>
          <Button type="button" variant="outline" onClick={()=>{
            if(role==="admin"){ setUsername("admin"); setPassword("123456"); }
            else { setUsername("sponsor"); setPassword("000000"); }
          }}>Preencher exemplo</Button>
        </div>
      </form>
    </main>
  );
}
