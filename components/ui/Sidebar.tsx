"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import { readSession, type Session } from "@/components/lib/session";

type Props = { role?: "admin" | "sponsor" };

export default function Sidebar(p: Props = {}) {
  const [s, setS] = useState<Session>({});

  useEffect(() => {
    const fromSess = readSession();
    setS({
      role: p.role ?? fromSess.role ?? "admin",
      brand: fromSess.brand,
      username: fromSess.username,
    });
  }, [p.role]);

  const role = s.role ?? "admin";

  const Item = ({ href, label }: { href: string; label: string }) => (
    <Link
      href={href}
      className="block rounded-xl border border-border bg-card px-4 py-3 transition hover:shadow-soft"
    >
      {label}
    </Link>
  );

  return (
    <aside className="space-y-3">
      {role === "admin" ? (
        <>
          <Item href="/" label="Overview" />
          <Item href="/projetos" label="Resultados" />
          <Item href="/pipeline" label="Financeiro" />
          <Item href="/settings" label="Settings" />
        </>
      ) : (
        <>
          <Item href={`/sponsor/${s.brand ?? "acme"}/overview`} label="Overview" />
          <Item href={`/sponsor/${s.brand ?? "acme"}/results`} label="Resultados" />
          <Item href={`/sponsor/${s.brand ?? "acme"}/financials`} label="Financeiro" />
          <Item href="/settings" label="Settings" />
        </>
      )}
    </aside>
  );
}
