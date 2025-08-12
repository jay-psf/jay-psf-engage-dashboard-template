"use client";
import { useState, useEffect } from "react";
import Link from "next/link";

type Role = "admin" | "sponsor";

export default function LoginForm(){
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState(""); const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(()=>{ setUsername("admin"); setPassword("123456"); },[]);

  const brandFromUser = (u:string) => u.toLowerCase()==="sponsor" ? "heineken" : "acme";

  async function onSubmit(e: React.FormEvent){
    e.preventDefault();
    const ok = (role==="admin" && username==="admin" && password==="123456")
            || (role==="sponsor" && username==="sponsor" && password==="000000");
    if(!ok){ alert("Usuário ou senha inválidos"); return; }

    setLoading(true);
    const brand = role==="sponsor" ? brandFromUser(username) : undefined;
    const resp = await fetch("/api/auth",{
      method:"POST", headers:{ "content-type":"application/json" },
      body: JSON.stringify({ role, brand }),
    });
    setLoading(false);
    if(!resp.ok){ alert("Falha ao autenticar"); return; }
    window.location.href = role==="sponsor" ? `/sponsor/${brand}/overview` : "/";
  }

  return (
    <div className="bg-card rounded-2xl shadow-strong border border-border p-6">
      <div className="mb-5">
        <div className="text-sm text-muted font-medium mb-2">Entrar como</div>
        <div className="relative bg-surface rounded-full p-1 border border-border flex">
          <button type="button"
            className={`flex-1 h-10 rounded-full transition ${role==="admin" ? "bg-[var(--accent)] text-white" : ""}`}
            onClick={()=>{ setRole("admin"); setUsername("admin"); setPassword("123456"); }}>
            Admin
          </button>
          <button type="button"
            className={`flex-1 h-10 rounded-full transition ${role==="sponsor" ? "bg-[var(--accent)] text-white" : ""}`}
            onClick={()=>{ setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}>
            Patrocinador
          </button>
        </div>
      </div>

      <form onSubmit={onSubmit} className="space-y-4">
        <label className="block">
          <div className="text-sm mb-1">Usuário</div>
          <input value={username} onChange={e=>setUsername(e.target.value)} className="input" placeholder={role==="admin"?"admin":"sponsor"} />
        </label>
        <label className="block">
          <div className="text-sm mb-1">Senha</div>
          <input value={password} onChange={e=>setPassword(e.target.value)} className="input" type="password" placeholder={role==="admin"?"123456":"000000"} />
        </label>

        <div className="flex items-center justify-between">
          <button type="submit" className="btn btn-primary">{loading ? "Entrando..." : "Entrar"}</button>
          <Link href="/forgot-password" className="text-sm text-[var(--accent)] hover:underline">Esqueci minha senha</Link>
        </div>
      </form>
    </div>
  );
}
