"use client";
import Link from "next/link";

export default function Sidebar({ role }: { role: "admin"|"sponsor" }){
  const items = role==="sponsor"
    ? [
        { href:"/sponsor/heineken/overview", label:"Overview" },
        { href:"/sponsor/heineken/results", label:"Resultados" },
        { href:"/sponsor/heineken/financials", label:"Financeiro" },
        { href:"/sponsor/heineken/events", label:"Eventos" },
        { href:"/sponsor/heineken/assets", label:"Assets" },
      ]
    : [
        { href:"/", label:"Overview" },
        { href:"/projetos", label:"Projetos" },
        { href:"/pipeline", label:"Pipeline" },
      ];
  return (
    <aside className="rounded-2xl border border-border bg-card p-4 shadow-soft">
      <nav className="space-y-3">
        {items.map((it)=>(
          <Link key={it.href} href={it.href}
            className="block rounded-xl border border-border bg-surface px-4 py-3 hover:shadow-soft transition">
            {it.label}
          </Link>
        ))}
        <Link href="/settings" className="block rounded-xl border border-border bg-surface px-4 py-3 hover:shadow-soft transition">Settings</Link>
      </nav>
    </aside>
  );
}
