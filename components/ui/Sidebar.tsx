"use client";
import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { usePathname } from "next/navigation";

type Session = { role?: "admin"|"sponsor"; brand?: string };
function readSession(): Session { try { const r=localStorage.getItem("session"); return r? JSON.parse(r):{}; } catch { return {}; } }

function NavItem({href, label}:{href:string; label:string}){
  const pathname = usePathname();
  const active = useMemo(()=> pathname===href || pathname.startsWith(href + "/"), [pathname, href]);
  return (
    <Link
      href={href}
      className={`rounded-[14px] border bg-card px-4 py-3 hover:shadow-soft transition block ${active? "ring-[3px] ring-[var(--ring)] border-transparent" : ""}`}
      aria-current={active ? "page" : undefined}
    >
      {label}
    </Link>
  );
}

export default function Sidebar(){
  const [s,setS]=useState<Session>({});
  useEffect(()=>{ setS(readSession()); },[]);
  const isSponsor = s.role==="sponsor";
  const brand = s.brand || "heineken";
  return (
    <aside className="hidden md:block w-[260px]">
      <div className="grid gap-2">
        {isSponsor ? (
          <>
            <NavItem href={`/sponsor/${brand}/overview`} label="Visão Geral" />
            <NavItem href={`/sponsor/${brand}/events`}   label="Eventos" />
            <NavItem href={`/sponsor/${brand}/results`}  label="Resultados" />
            <NavItem href={`/sponsor/${brand}/financials`} label="Financeiro" />
            <NavItem href={`/sponsor/${brand}/assets`}   label="Assets" />
          </>
        ) : (
          <>
            <NavItem href="/"          label="Dashboard" />
            <NavItem href="/pipeline"  label="Pipeline" />
            <NavItem href="/projetos"  label="Projetos" />
            <NavItem href="/admin"     label="Admin" />
          </>
        )}
      </div>
    </aside>
  );
}
