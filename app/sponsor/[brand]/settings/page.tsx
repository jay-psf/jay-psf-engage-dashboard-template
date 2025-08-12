"use client";
import { useEffect, useMemo, useState } from "react";
import Button from "@/components/ui/Button";

type ThemePref = "light" | "dark" | "system";

function formatCNPJ(v:string){
  const d = v.replace(/\D/g,"").slice(0,14);
  return d
    .replace(/^(\d{2})(\d)/, "$1.$2")
    .replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3")
    .replace(/\.(\d{3})(\d)/, ".$1/$2")
    .replace(/(\d{4})(\d)/, "$1-$2");
}
function formatPhone(v:string){
  const d = v.replace(/\D/g,"").slice(0,11);
  if (d.length <= 10) {
    return d.replace(/^(\d{0,2})(\d{0,4})(\d{0,4}).*/, (_,a,b,c)=>[
      a?`(${a}`:"", a&&a.length===2?") ":"", b, b&&c?"-":"", c
    ].join(""));
  }
  return d.replace(/^(\d{2})(\d{5})(\d{4}).*/, "($1) $2-$3");
}

export default function SponsorSettingsPage({ params }: { params: { brand: string } }) {
  const brand = params.brand;
  const storageKey = useMemo(()=>`sponsorProfile-${brand}`,[brand]);

  const [pref, setPref] = useState<ThemePref>("system");
  const [company, setCompany] = useState("");
  const [cnpj, setCNPJ] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [contact, setContact] = useState("");

  // carrega preferências/dados
  useEffect(()=>{
    const p = window.localStorage.getItem("themePref") as ThemePref | null;
    if (p) setPref(p);
    const raw = window.localStorage.getItem(storageKey);
    if (raw) {
      try {
        const s = JSON.parse(raw);
        setCompany(s.company ?? "");
        setCNPJ(s.cnpj ?? "");
        setEmail(s.email ?? "");
        setPhone(s.phone ?? "");
        setContact(s.contact ?? "");
      } catch {}
    }
  },[storageKey]);

  // aplica tema
  useEffect(()=>{
    if (pref === "system") {
      window.localStorage.setItem("themePref","system");
      const mq = window.matchMedia("(prefers-color-scheme: dark)");
      document.documentElement.setAttribute("data-theme", mq.matches ? "dark" : "light");
      const l = (e:MediaQueryListEvent)=>document.documentElement.setAttribute("data-theme", e.matches?"dark":"light");
      mq.addEventListener?.("change", l);
      return ()=>mq.removeEventListener?.("change", l);
    } else {
      window.localStorage.setItem("themePref",pref);
      document.documentElement.setAttribute("data-theme", pref);
    }
  },[pref]);

  function save() {
    const payload = { company, cnpj, email, phone, contact };
    window.localStorage.setItem(storageKey, JSON.stringify(payload));
    alert("Informações salvas!");
  }

  return (
    <main className="space-y-6">
      <section className="rounded-2xl border border-[var(--borderC)] bg-[var(--card)] p-5 shadow-soft">
        <h2 className="text-base font-semibold mb-3">Tema</h2>
        <div className="grid gap-3 sm:grid-cols-3">
          {(["light","dark","system"] as ThemePref[]).map(t=>(
            <button
              key={t}
              onClick={()=>setPref(t)}
              className={[
                "rounded-2xl border p-4 text-left transition",
                "border-[var(--borderC)] bg-[var(--surface)]/40 hover:bg-[var(--surface)]/70",
                pref===t ? "ring-4 ring-[var(--ring)]" : ""
              ].join(" ")}
            >
              <div className="text-sm text-[var(--muted)]">Preferência</div>
              <div className="mt-1 font-medium capitalize">{t}</div>
            </button>
          ))}
        </div>
      </section>

      <section className="rounded-2xl border border-[var(--borderC)] bg-[var(--card)] p-5 shadow-soft">
        <h2 className="text-base font-semibold mb-4">Informações da Empresa</h2>
        <div className="grid gap-4 md:grid-cols-2">
          <label className="block">
            <div className="mb-1 text-sm">Razão Social</div>
            <input className="input" value={company} onChange={(e)=>setCompany(e.target.value)} placeholder="Heineken Brasil" />
          </label>
          <label className="block">
            <div className="mb-1 text-sm">CNPJ</div>
            <input className="input" value={cnpj} onChange={(e)=>setCNPJ(formatCNPJ(e.target.value))} placeholder="00.000.000/0000-00" />
          </label>
          <label className="block">
            <div className="mb-1 text-sm">E-mail</div>
            <input className="input" value={email} onChange={(e)=>setEmail(e.target.value)} placeholder="contato@empresa.com.br" />
          </label>
          <label className="block">
            <div className="mb-1 text-sm">Telefone</div>
            <input className="input" value={phone} onChange={(e)=>setPhone(formatPhone(e.target.value))} placeholder="(11) 90000-0000" />
          </label>
          <label className="block md:col-span-2">
            <div className="mb-1 text-sm">Responsável</div>
            <input className="input" value={contact} onChange={(e)=>setContact(e.target.value)} placeholder="Nome do contato" />
          </label>
        </div>

        <div className="mt-5">
          <Button size="lg" onClick={save}>Salvar</Button>
        </div>
      </section>
    </main>
  );
}
