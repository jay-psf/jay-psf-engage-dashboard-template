"use client";
import Image from "next/image";
import Link from "next/link";
import Button from "./Button";
import { useEffect, useState } from "react";

type Session = { role?: "admin"|"sponsor"; brand?: string; username?: string };
function readSession(): Session { try { const r=localStorage.getItem("session"); return r? JSON.parse(r):{}; } catch { return {}; } }

export default function Topbar(){
  const [s,setS] = useState<Session>({});
  useEffect(()=>{ setS(readSession()); },[]);
  const isSponsor = s.role==="sponsor";
  const brand = s.brand || "heineken";
  return (
    <header className="sticky top-0 z-30 border bg-card/90 backdrop-blur supports-[backdrop-filter]:bg-card/80">
      <div className="container-main h-16 flex items-center justify-between">
        <div className="flex items-center gap-3">
          {isSponsor ? (
            <Image src={`/logos/${brand}.png`} alt={`${brand} logo`} width={120} height={28} className="object-contain" priority />
          ) : (
            <Link href="/" className="h-display text-lg">Entourage • Engage</Link>
          )}
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" onClick={()=>{
            localStorage.removeItem("session");
            document.documentElement.removeAttribute("data-theme");
            window.location.href="/login";
          }}>Sair</Button>
        </div>
      </div>
    </header>
  );
}
