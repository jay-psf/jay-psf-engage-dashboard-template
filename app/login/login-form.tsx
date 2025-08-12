"use client";
import { useState, useEffect } from "react";
import Button from "@/components/ui/Button";

type Role = "admin" | "sponsor";

export default function LoginForm(){
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(()=>{ setUsername("admin"); setPassword("123456"); }, []);

  function resolveBrandFromUser(u: string){ return u.toLowerCase() === "sponsor" ? "heineken" : "acme"; }

  async function onSubmit(e: React.FormEvent){
    e.preventDefault();
    const ok = (role==="admin" && username==="admin" && password==="123456")
            || (role==="sponsor" && username==="sponsor" && password==="000000");
    if(!ok) return alert("Usuário ou senha inválidos");
    setLoading(true);
    const brand = role==="sponsor" ? resolveBrandFromUser(username) : undefined;
    const resp = await fetch("/api/auth", { method:"POST", headers:{ "content-type":"application/json" }, body: JSON.stringify({ role, brand }) });
    setLoading(false);
    if(!resp.ok) return alert("Falha ao autenticar");
    window.location.href = role==="sponsor" ? `/sponsor/${brand}/overview` : "/";
  }

  return (
    <div className="min-h-[calc(100vh-64px)] grid place-items-center px-4">
      <div className="w-full max-w-md bg-card border border-border rounded-2xl p-6 shadow-soft">
        <div className="text-center text-xl font-semibold">Entrar</div>

        {/* Toggle deslizante */}
        <div className="mt-4 relative bg-surface border border-border rounded-2xl p-1 grid grid-cols-2">
          <div
            className="absolute top-1 bottom-1 w-1/2 rounded-xl bg-[var(--accent)] transition-transform"
            style={{ transform: role==="admin" ? "translateX(0%)" : "translateX(100%)" }}
          />
          <button type="button" onClick={()=>{ setRole("admin"); setUsername("admin"); setPassword("123456"); }}
            className={["relative z-10 h-10 rounded-xl", role==="admin" ? "text-white" : "text-[var(--text)]"].join(" ")}
          >Admin</button>
          <button type="button" onClick={()=>{ setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}
            className={["relative z-10 h-10 rounded-xl", role==="sponsor" ? "text-white" : "text-[var(--text)]"].join(" ")}
          >Patrocinador</button>
        </div>

        <form onSubmit={onSubmit} className="mt-5 space-y-3">
          <label className="block">
            <div className="text-sm mb-1">Usuário</div>
            <input value={username} onChange={(e)=>setUsername(e.target.value)} className="input" placeholder={role==="admin"?"admin":"sponsor"} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">Senha</div>
            <input value={password} onChange={(e)=>setPassword(e.target.value)} className="input" type="password" placeholder={role==="admin"?"123456":"000000"} />
          </label>

          <div className="pt-2 flex gap-2">
            <Button type="submit" size="lg">{loading ? "Entrando..." : "Entrar"}</Button>
            <Button type="button" variant="outline" onClick={()=>{
              if(role==="admin"){ setUsername("admin"); setPassword("123456"); }
              else { setUsername("sponsor"); setPassword("000000"); }
            }}>Preencher exemplo</Button>
          </div>
        </form>
      </div>
    </div>
  );
}
