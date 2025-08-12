"use client";
import { useEffect, useState } from "react";

type ThemeOpt = "light" | "dark" | "system";

export default function SponsorSettings(){
  const [theme, setTheme] = useState<ThemeOpt>("system");
  const [nome, setNome] = useState("");
  const [cnpj, setCnpj] = useState("");
  const [email, setEmail] = useState("");
  const [fone, setFone] = useState("");

  useEffect(()=>{
    const pref = localStorage.getItem("theme-pref") as ThemeOpt | null;
    setTheme(pref || "system");
  },[]);

  useEffect(()=>{
    const html = document.documentElement;
    if(theme === "system"){
      const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
      html.setAttribute("data-theme", prefersDark ? "dark" : "light");
    }else{
      html.setAttribute("data-theme", theme);
    }
    localStorage.setItem("theme-pref", theme);
  },[theme]);

  return (
    <main className="grid gap-6">
      <section className="card p-5">
        <h2 className="font-semibold mb-3">Aparência</h2>
        <div className="flex gap-2">
          {(["light","dark","system"] as ThemeOpt[]).map(t=>(
            <button
              key={t}
              onClick={()=>setTheme(t)}
              className={`btn ${theme===t?"btn-primary":""}`}
            >
              {t[0].toUpperCase()+t.slice(1)}
            </button>
          ))}
        </div>
      </section>

      <section className="card p-5">
        <h2 className="font-semibold mb-3">Dados da empresa</h2>
        <div className="grid md:grid-cols-2 gap-4">
          <label className="block">
            <div className="text-sm mb-1">Nome</div>
            <input className="input" value={nome} onChange={e=>setNome(e.target.value)} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">CNPJ</div>
            <input className="input" value={cnpj} onChange={e=>setCnpj(e.target.value)} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">E-mail</div>
            <input className="input" value={email} onChange={e=>setEmail(e.target.value)} />
          </label>
          <label className="block">
            <div className="text-sm mb-1">Telefone</div>
            <input className="input" value={fone} onChange={e=>setFone(e.target.value)} />
          </label>
        </div>
      </section>
    </main>
  );
}
