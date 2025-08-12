"use client";
import Link from "next/link";
import type { Role } from "@/components/lib/types";

export default function Sidebar({ role }: { role?: Role }) {
  const isSponsor = role === "sponsor";

  const adminNav = [
    { href: "/", label: "Overview" },
    { href: "/pipeline", label: "Pipeline" },
    { href: "/projetos", label: "Projetos" },
    { href: "/settings", label: "Settings" },
  ];
  const sponsorNav = [
    { href: "/sponsor/heineken/overview", label: "Overview" },
    { href: "/sponsor/heineken/results", label: "Resultados" },
    { href: "/sponsor/heineken/financials", label: "Financeiro" },
    { href: "/settings", label: "Settings" },
  ];

  const nav = isSponsor ? sponsorNav : adminNav;

  return (
    <aside className="rounded-2xl border border-border bg-card p-3 h-fit">
      <nav className="flex flex-col gap-2">
        {nav.map((i) => (
          <Link key={i.href} href={i.href} className="block rounded-xl border border-border bg-card px-4 py-3 transition hover:shadow-soft">
            {i.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
}
