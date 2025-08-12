set -euo pipefail

echo "== 1) Helper de sessão (cookies + fallback localStorage) =="
mkdir -p components/lib
cat > components/lib/session.ts <<'TS'
"use client";

export type Role = "admin" | "sponsor";
export type Session = { role?: Role; brand?: string; username?: string };

function getCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  const pairs = document.cookie.split("; ").map(s => s.split("="));
  const hit = pairs.find(([k]) => k === name);
  return hit ? decodeURIComponent(hit[1] ?? "") : undefined;
}

export function readSession(): Session {
  try {
    // Cookies (fonte oficial após /api/auth)
    const role = getCookie("role") as Role | undefined;
    const brand = getCookie("brand") || undefined;
    if (role) return { role, brand };

    // Fallback dev: localStorage
    const raw = typeof window !== "undefined" ? window.localStorage.getItem("session") : null;
    return raw ? (JSON.parse(raw) as Session) : {};
  } catch {
    return {};
  }
}
TS

echo "== 2) Topbar lê sessão e props são opcionais =="
mkdir -p components/ui
cat > components/ui/Topbar.tsx <<'TSX'
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
TSX

echo "== 3) Sidebar lê sessão e props são opcionais =="
cat > components/ui/Sidebar.tsx <<'TSX'
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
TSX

echo "== 4) Build =="
pnpm build 2>&1 | tee .last_build.log
echo
echo "== Últimas 120 linhas do build =="
tail -n 120 .last_build.log
