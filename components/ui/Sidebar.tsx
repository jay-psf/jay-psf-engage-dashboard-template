"use client";
import Link from "next/link";
import { useEffect, useState } from "react";

type Session = { role?: "admin" | "sponsor"; brand?: string };

function readSession(): Session {
  try { const raw = localStorage.getItem("session"); return raw ? JSON.parse(raw) : {}; }
  catch { return {}; }
}

export default function Sidebar() {
  const [s, setS] = useState<Session>({});
  useEffect(() => setS(readSession()), []);

  const isSponsor = s.role === "sponsor";
  const brand = (s.brand || "acme").toLowerCase();

  const adminNav = [
    { href: "/", label: "Dashboard" },
    { href: "/pipeline", label: "Pipeline" },
    { href: "/projetos", label: "Projetos" },
    { href: "/admin", label: "Admin" },
  ];

  const sponsorNav = [
    { href: `/sponsor/${brand}/overview`, label: "Overview" },
    { href: `/sponsor/${brand}/results`, label: "Resultados" },
    { href: `/sponsor/${brand}/financials`, label: "Financeiro" },
  ];

  const items = isSponsor ? sponsorNav : [...adminNav, ...sponsorNav];

  return (
    <aside className="w-[260px] shrink-0">
      <nav className="space-y-3">
        {items.map((i) => (
          <Link
            key={i.href}
            href={i.href}
            className="block rounded-xl border border-border bg-card px-4 py-3 hover:shadow-soft transition"
          >
            {i.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
}
