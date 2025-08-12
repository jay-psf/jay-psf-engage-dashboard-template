"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { readSession } from "@/components/lib/session";

function Item({ href, label }: { href: string; label: string }) {
  const pathname = usePathname();
  const active = pathname === href;
  return (
    <Link
      href={href}
      className={`block rounded-2xl border px-4 py-3 text-sm transition ${
        active ? "bg-accent text-white border-accent" : "bg-card border-border hover:shadow-soft"
      }`}
    >
      {label}
    </Link>
  );
}

export default function Sidebar() {
  const { role, brand } = readSession();

  if (!role) return null; // não aparece enquanto não loga

  const sponsorBase = `/sponsor/${brand ?? "acme"}`;

  const items =
    role === "sponsor"
      ? [
          { href: `${sponsorBase}/overview`, label: "Overview" },
          { href: `${sponsorBase}/results`, label: "Resultados" },
          { href: `${sponsorBase}/financials`, label: "Financeiro" },
          { href: `${sponsorBase}/events`, label: "Eventos" },
          { href: `${sponsorBase}/assets`, label: "Assets" },
          { href: `/settings`, label: "Settings" },
        ]
      : [
          { href: "/", label: "Overview" },
          { href: "/projetos", label: "Resultados" },
          { href: "/pipeline", label: "Financeiro" },
          { href: "/settings", label: "Settings" },
        ];

  return (
    <aside className="hidden md:block">
      <nav className="flex w-[260px] flex-col gap-4">
        {items.map((i) => (
          <Item key={i.href} href={i.href} label={i.label} />
        ))}
      </nav>
    </aside>
  );
}
