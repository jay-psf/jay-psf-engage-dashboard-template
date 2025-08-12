"use client";
import { useState, useEffect } from "react";
import Button from "@/components/ui/Button";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  useEffect(()=>{ setUsername("admin"); setPassword("123456"); },[]);

  async function onSubmit(e: React.FormEvent){
    e.preventDefault();
    const ok = (role==="admin" && username==="admin" && password==="123456")
            || (role==="sponsor" && username==="sponsor" && password==="000000");
    if(!ok){ alert("Usuário ou senha inválidos"); return; }

    const session = { role, username, brand: role==="sponsor" ? "heineken" : undefined };
    localStorage.setItem("session", JSON.stringify(session));

    if (role==="sponsor"){
      document.documentElement.setAttribute("data-theme","dark");
      window.location.href = `/sponsor/${session.brand}/overview`;
    } else {
      document.documentElement.removeAttribute("data-theme");
      window.location.href = "/";
    }
  }

  return (
    <div className="w-full max-w-4xl mx-auto space-y-6 fade-in">
      <div className="grid md:grid-cols-2 gap-4">
        <button onClick={()=>setRole("admin")}
          className={`text-left rounded-[18px] border px-5 py-4 bg-card hover:shadow-soft transition ${role==="admin"?"ring-[3px] ring-[var(--ring)] border-transparent":""}`}>
          <div className="text-xs uppercase tracking-wide text-muted">Perfil</div>
          <div className="mt-1 h-display text-xl">Interno (Admin)</div>
          <div className="text-sm text-muted mt-1">Acesso completo</div>
        </button>

        <button onClick={()=>setRole("sponsor")}
          className={`text-left rounded-[18px] border px-5 py-4 bg-card hover:shadow-soft transition ${role==="sponsor"?"ring-[3px] ring-[var(--ring)] border-transparent":""}`}>
          <div className="text-xs uppercase tracking-wide text-muted">Perfil</div>
          <div className="mt-1 h-display text-xl">Patrocinador</div>
          <div className="text-sm text-muted mt-1">Acompanha seu contrato</div>
        </button>
      </div>

      <form onSubmit={onSubmit} className="card p-6 space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <label className="block">
            <div className="text-sm mb-1">Usuário</div>
            <input value={username} onChange={(e)=>setUsername(e.target.value)}
              className="input" placeholder={role==="admin"?"admin":"sponsor"} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">Senha</div>
            <input value={password} onChange={(e)=>setPassword(e.target.value)}
              className="input" placeholder={role==="admin"?"123456":"000000"} type="password" />
          </label>
        </div>

        <div className="flex gap-3 pt-2">
          <Button type="submit" size="lg" className="px-6">Entrar</Button>
          <Button type="button" variant="outline" onClick={()=>{
            if(role==="admin"){ setUsername("admin"); setPassword("123456"); }
            else { setUsername("sponsor"); setPassword("000000"); }
          }}>Preencher exemplo</Button>
        </div>
      </form>
    </div>
  );
}
