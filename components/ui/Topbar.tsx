"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import { readSession } from "@/components/lib/session";

export default function Topbar() {
  const [{ role, brand }, setSession] = useState<{role?: "admin"|"sponsor"; brand?: string}>({});

  useEffect(() => {
    setSession(readSession());
  }, []);

  function toggleSidebar() {
    const html = document.documentElement;
    const cur = html.getAttribute("data-sidebar");
    html.setAttribute("data-sidebar", cur === "open" ? "closed" : "open");
  }

  async function logout() {
    await fetch("/api/logout", { method: "POST" });
    window.location.href = "/login";
  }

  return (
    <header className="sticky top-0 z-40 bg-surface/80 backdrop-blur border-b border-border">
      <div className="mx-auto max-w-screen-2xl px-4 py-3 flex items-center gap-3">
        {/* Hamburger mobile */}
        <button
          aria-label="Abrir menu"
          onClick={toggleSidebar}
          className="md:hidden inline-flex items-center gap-2 rounded-xl border border-border bg-card px-3 py-2"
        >
          <span style={{width:20,height:2,background:"currentColor",display:"block",borderRadius:2}} />
          <span style={{width:20,height:2,background:"currentColor",display:"block",borderRadius:2,marginTop:3}} />
          <span style={{width:20,height:2,background:"currentColor",display:"block",borderRadius:2,marginTop:3}} />
        </button>

        <Link href="/" className="mr-auto font-semibold">Engage</Link>

        {/* Pílula com apenas o logo do brand (se sponsor) */}
        {role === "sponsor" && (
          <div className="rounded-2xl border border-border bg-card px-3 py-1.5 flex items-center gap-2">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={`/logos/${brand ?? "acme"}.png`}
              alt={brand ?? "brand"}
              width={22}
              height={22}
              className="brand-logo"
              style={{ borderRadius: 6, display: "block" }}
            />
          </div>
        )}

        <button onClick={logout} className="ml-2 rounded-xl border border-border bg-card px-4 py-2">
          Sair
        </button>
      </div>
    </header>
  );
}
