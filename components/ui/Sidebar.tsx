"use client";
import Link from "next/link";
import { useEffect, useState } from "react";

type Session = { role: "admin" | "sponsor"; brand?: string };

function readSession(): Session {
  try {
    const raw = localStorage.getItem("session");
    return raw ? JSON.parse(raw) as Session : { role: "admin" };
  } catch {
    return { role: "admin" };
  }
}

function Item({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link
      href={href}
      className="block w-full rounded-xl border border-border bg-surface hover:border-accent/50 hover:shadow-soft px-4 h-11 text-sm flex items-center"
    >
      {children}
    </Link>
  );
}

export default function Sidebar() {
  const [s, setS] = useState<Session>({ role: "admin" });
  useEffect(() => setS(readSession()), []);

  const sponsorOnly = [
    { href: "/sponsor/[brand]/overview", label: "Overview" },
    { href: "/sponsor/[brand]/results", label: "Resultados" },
    { href: "/sponsor/[brand]/financials", label: "Financeiro" },
  ];

  const adminOnly = [
    { href: "/", label: "Dashboard" },
    { href: "/pipeline", label: "Pipeline" },
    { href: "/projetos", label: "Projetos" },
    { href: "/admin", label: "Admin" },
  ];

  const items = s.role === "sponsor" ? sponsorOnly : [...adminOnly, ...sponsorOnly];

  // Monta path correto quando sponsor (substitui [brand])
  const brand = (s.brand || "acme").toLowerCase();

  return (
    <aside className="w-64 shrink-0 p-4 space-y-3">
      {items.map((i) => {
        const href = i.href.replace("[brand]", brand);
        return <Item key={i.href} href={href}>{i.label}</Item>;
      })}
    </aside>
  );
}
