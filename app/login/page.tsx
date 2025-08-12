"use client";
import { useEffect, useState } from "react";
import RoleSwitch from "@/components/ui/RoleSwitch";
import Button from "@/components/ui/Button";

export default function LoginPage(){
  const [role, setRole] = useState<"admin"|"sponsor">("admin");
  const [username, setUsername] = useState("admin");
  const [password, setPassword] = useState("123456");
  const [loading, setLoading] = useState(false);

  useEffect(()=>{
    if(role==="admin"){ setUsername("admin"); setPassword("123456"); }
    else { setUsername("sponsor"); setPassword("000000"); }
  },[role]);

  async function submit(e:React.FormEvent){
    e.preventDefault(); setLoading(true);
    try{
      const r = await fetch("/api/auth",{ method:"POST", headers:{ "Content-Type":"application/json" }, body: JSON.stringify({ username, password, role })});
      if(r.ok){
        if(role==="admin") window.location.href="/admin";
        else window.location.href="/sponsor/heineken/overview";
      } else {
        alert("Usuário ou senha inválidos.");
      }
    } finally{ setLoading(false); }
  }

  return (
    <div className="min-h-[calc(100vh-40px)] grid place-items-center px-4">
      <div className="card w-full max-w-xl p-8">
        <div className="flex flex-col items-center gap-6">
          <h1 className="text-2xl font-semibold">Entrar</h1>
          <RoleSwitch value={role} onChange={setRole} />
          <form onSubmit={submit} className="w-full mt-4 space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm mb-1 text-[var(--muted)]">Usuário</label>
                <input
                  value={username} onChange={e=>setUsername(e.target.value)}
                  className="pill w-full h-11 px-3 bg-[var(--surface)]"
                  autoComplete="username"
                />
              </div>
              <div>
                <label className="block text-sm mb-1 text-[var(--muted)]">Senha</label>
                <input
                  type="password"
                  value={password} onChange={e=>setPassword(e.target.value)}
                  className="pill w-full h-11 px-3 bg-[var(--surface)]"
                  autoComplete="current-password"
                />
              </div>
            </div>
            <div className="pt-2 flex gap-3 justify-center">
              <Button type="submit" size="lg" className="lumen">
                {loading ? "Entrando..." : "Entrar"}
              </Button>
              <Button type="button" variant="outline"
                onClick={()=>{ if(role==="admin"){ setUsername("admin"); setPassword("123456"); } else { setUsername("sponsor"); setPassword("000000"); }}}>
                Preencher exemplo
              </Button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
