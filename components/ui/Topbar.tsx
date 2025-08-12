"use client";
import Image from "next/image";
import { useEffect, useState } from "react";
import { readSession, type Session } from "@/components/lib/session";

type Props = { role?: "admin" | "sponsor"; brand?: string };

export default function Topbar(p: Props = {}) {
  const [s, setS] = useState<Session>({});

  useEffect(() => {
    const fromSess = readSession();
    setS({
      role: p.role ?? fromSess.role ?? "admin",
      brand: p.brand ?? fromSess.brand,
      username: fromSess.username,
    });
  }, [p.role, p.brand]);

  const isSponsor = s.role === "sponsor";
  const brandLogo =
    isSponsor && (s.brand?.toLowerCase() === "heineken")
      ? "/logos/heineken.png"
      : undefined;

  return (
    <header className="sticky top-0 z-30 border-b border-border bg-card/85 backdrop-blur">
      <div className="mx-auto flex max-w-screen-2xl items-center justify-between px-6 py-3">
        <div className="flex items-center gap-3">
          <span className="inline-block h-2.5 w-2.5 rounded-full bg-[var(--accent)]" />
          <span className="font-medium">Engage Dashboard</span>
          {isSponsor && brandLogo && (
            <span className="ml-3 inline-flex items-center gap-2 rounded-xl border border-border bg-surface px-2.5 py-1 text-xs">
              <Image src={brandLogo} alt={s.brand ?? "brand"} width={18} height={18} />
              <span className="opacity-80">{s.brand}</span>
            </span>
          )}
        </div>

        <div className="flex items-center gap-3">
          <div className="h-8 w-8 overflow-hidden rounded-full border border-border bg-surface" />
          <a href="/settings" className="rounded-lg border border-border px-3 py-1.5 text-sm hover:opacity-90">
            Settings
          </a>
        </div>
      </div>
    </header>
  );
}
