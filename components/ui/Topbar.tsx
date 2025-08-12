"use client";
import Image from "next/image";
import { useState } from "react";

export default function Topbar({ role, brand }: { role:"admin"|"sponsor"; brand?: string }){
  const [loading, setLoading] = useState(false);

  async function logout(){
    setLoading(true);
    try{
      await fetch("/api/logout",{ method:"POST" });
      window.location.href = "/login";
    }finally{ setLoading(false); }
  }

  const showLogo = role==="sponsor" && brand;
  const logoSrc = brand ? `/logos/${brand}.png` : undefined;

  return (
    <header className="sticky top-0 z-30 bg-[var(--bg)]/80 backdrop-blur-md">
      <div className="mx-auto max-w-screen-2xl flex items-center justify-between p-4">
        <div className="flex items-center gap-3">
          <div className="h-3 w-3 rounded-full" style={{background:"var(--accent)"}}/>
          <span className="font-semibold">Engage Dashboard</span>
        </div>

        <div className="flex items-center gap-4">
          {showLogo && logoSrc ? (
            <Image src={logoSrc} alt={`${brand} logo`} width={88} height={24} priority />
          ) : null}

          <a href="/settings" className="flex items-center gap-2 rounded-full border border-border bg-card px-3 py-1.5 hover:shadow-soft">
            <div className="h-8 w-8 rounded-full bg-surface grid place-items-center border border-border">👤</div>
            <span className="text-sm text-muted hidden sm:inline">Perfil</span>
          </a>

          <button onClick={logout} disabled={loading}
            className="px-3 py-1.5 rounded-lg border text-sm hover:shadow-soft">
            {loading ? "Saindo..." : "Sair"}
          </button>
        </div>
      </div>
    </header>
  );
}
