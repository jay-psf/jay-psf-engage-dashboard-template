"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import { readSession } from "@/components/lib/session";

function NavItem({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link
      href={href}
      className="block rounded-2xl border border-border bg-card px-4 py-3 transition hover:shadow-soft"
      onClick={() => document.documentElement.setAttribute("data-sidebar", "closed")}
    >
      {children}
    </Link>
  );
}

export default function Sidebar() {
  const [{ role, brand }, setSession] = useState<{role?: "admin"|"sponsor"; brand?: string}>({});

  useEffect(() => {
    setSession(readSession());
  }, []);

  return (
    <>
      {/* Scrim mobile */}
      <div className="SidebarScrim md:hidden" onClick={() => document.documentElement.setAttribute("data-sidebar", "closed")} />

      {/* Drawer mobile */}
      <aside className="SidebarMobile md:hidden p-4 space-y-3 border border-border">
        {role === "sponsor" ? (
          <>
            <NavItem href={`/sponsor/${brand}/overview`}>Overview</NavItem>
            <NavItem href={`/sponsor/${brand}/results`}>Resultados</NavItem>
            <NavItem href={`/sponsor/${brand}/financials`}>Financeiro</NavItem>
            <NavItem href={`/sponsor/${brand}/events`}>Eventos</NavItem>
            <NavItem href={`/sponsor/${brand}/assets`}>Assets</NavItem>
            <NavItem href={`/sponsor/${brand}/settings`}>Settings</NavItem>
          </>
        ) : (
          <>
            <NavItem href="/">Overview</NavItem>
            <NavItem href="/projetos">Resultados</NavItem>
            <NavItem href="/pipeline">Financeiro</NavItem>
            <NavItem href="/settings">Settings</NavItem>
          </>
        )}
      </aside>

      {/* Sidebar desktop */}
      <aside className="hidden md:block w-[260px]">
        <div className="p-4 space-y-3">
          {role === "sponsor" ? (
            <>
              <NavItem href={`/sponsor/${brand}/overview`}>Overview</NavItem>
              <NavItem href={`/sponsor/${brand}/results`}>Resultados</NavItem>
              <NavItem href={`/sponsor/${brand}/financials`}>Financeiro</NavItem>
              <NavItem href={`/sponsor/${brand}/events`}>Eventos</NavItem>
              <NavItem href={`/sponsor/${brand}/assets`}>Assets</NavItem>
              <NavItem href={`/sponsor/${brand}/settings`}>Settings</NavItem>
            </>
          ) : (
            <>
              <NavItem href="/">Overview</NavItem>
              <NavItem href="/projetos">Resultados</NavItem>
              <NavItem href="/pipeline">Financeiro</NavItem>
              <NavItem href="/settings">Settings</NavItem>
            </>
          )}
        </div>
      </aside>
    </>
  );
}
