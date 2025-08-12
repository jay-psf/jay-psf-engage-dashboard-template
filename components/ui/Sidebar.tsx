"use client";
import Link from "next/link";

function Item({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link
      href={href}
      className="block rounded-xl border border-border bg-card px-4 py-3 hover:shadow-soft transition"
    >
      {children}
    </Link>
  );
}

export default function Sidebar({ role, brand }: { role: "admin"|"sponsor"; brand?: string }) {
  const isSponsor = role === "sponsor";
  return (
    <aside className="space-y-2">
      {!isSponsor && (
        <>
          <Item href="/">Dashboard</Item>
          <Item href="/pipeline">Pipeline</Item>
          <Item href="/projetos">Projetos</Item>
          <Item href="/admin">Admin</Item>
        </>
      )}
      {isSponsor && (
        <>
          <Item href={`/sponsor/${brand}/overview`}>Visão Geral</Item>
          <Item href={`/sponsor/${brand}/events`}>Eventos</Item>
          <Item href={`/sponsor/${brand}/assets`}>Ativos</Item>
          <Item href={`/sponsor/${brand}/results`}>Resultados</Item>
          <Item href={`/sponsor/${brand}/financials`}>Financeiro</Item>
        </>
      )}
    </aside>
  );
}
