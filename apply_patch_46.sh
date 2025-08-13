#!/usr/bin/env bash
set -euo pipefail
echo "== Patch 46: next/image nos logos + RoleSwitch sem warning + respiro no conteúdo =="

# --- 1) Topbar: usa next/image e cliques corretos ---
mkdir -p components/ui
cat > components/ui/Topbar.tsx <<'TSX'
"use client";

import Link from "next/link";
import Image from "next/image";
import { usePathname, useRouter } from "next/navigation";
import { readSession } from "@/components/lib/session";
import Button from "@/components/ui/Button";

export default function Topbar(){
  const pathname = usePathname();
  const router = useRouter();
  const { role, brand } = readSession();

  const isSponsor = role === "sponsor";
  const sBase = brand ? `/sponsor/${brand}` : "/sponsor/acme";

  const mainNav = isSponsor ? [
    { href: `${sBase}/overview`,   label: "Overview",   active: pathname.startsWith(`${sBase}/overview`) },
    { href: `${sBase}/results`,    label: "Resultados", active: pathname.startsWith(`${sBase}/results`) },
    { href: `${sBase}/financials`, label: "Financeiro", active: pathname.startsWith(`${sBase}/financials`) },
    { href: `${sBase}/events`,     label: "Eventos",    active: pathname.startsWith(`${sBase}/events`) },
    { href: `${sBase}/assets`,     label: "Assets",     active: pathname.startsWith(`${sBase}/assets`) },
    { href: `${sBase}/settings`,   label: "Settings",   active: pathname.startsWith(`${sBase}/settings`) },
  ] : [
    { href: "/admin",        label: "Overview",  active: pathname === "/admin" },
    { href: "/admin/users",  label: "Usuários",  active: pathname.startsWith("/admin/users") },
    { href: "/settings",     label: "Settings",  active: pathname.startsWith("/settings") },
  ];

  const onLogout = async () => {
    try { await fetch("/api/logout", { method:"POST" }); }
    finally { window.location.href = "/login"; }
  };

  // resolve logo do patrocinador
  const brandLogo = (b?: string) => `/logos/${(b||"acme").toLowerCase()}.png`;

  return (
    <header className="sticky top-0 z-40 backdrop-blur-md bg-[color:var(--glass)] border-b border-[color:var(--borderC)]">
      <div className="mx-auto max-w-screen-2xl px-4 md:px-6 h-16 flex items-center gap-4">
        {/* Logo Engage -> home */}
        <button
          onClick={() => router.push("/")}
          aria-label="Ir para Home"
          className="inline-flex items-center gap-2 hover:opacity-90 transition"
        >
          <Image src="/engage-logo.svg" alt="Engage" width={24} height={24} priority />
          <span className="font-semibold tracking-tight">Engage</span>
        </button>

        {/* Navegação principal */}
        <nav className="hidden md:flex items-center gap-2">
          {mainNav.map(item => (
            <Link
              key={item.href}
              href={item.href}
              className={[
                "px-3 py-1.5 rounded-full transition",
                item.active ? "bg-[var(--surface)] text-[var(--text)] shadow-sm" : "text-[var(--muted)] hover:text-[var(--text)]"
              ].join(" ")}
            >
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="ml-auto flex items-center gap-3">
          {/* Chip da marca (logo maior, sem texto). Clica -> perfil do patrocinador */}
          {isSponsor && (
            <button
              onClick={() => router.push(`${sBase}/overview`)}
              className="rounded-full p-1.5 hover:shadow-[var(--halo)] transition"
              aria-label="Ir ao perfil do patrocinador"
            >
              <Image
                src={brandLogo(brand)}
                alt={brand ?? "brand"}
                width={44} height={44}
                style={{ borderRadius: 10, objectFit: "cover" }}
              />
            </button>
          )}

          <Button variant="outline" onClick={onLogout}>Sair</Button>
        </div>
      </div>
    </header>
  );
}
TSX

# --- 2) RoleSwitch: corrige useEffect/dep e remove warnings ---
mkdir -p components/ui
cat > components/ui/RoleSwitch.tsx <<'TSX'
"use client";
import { useEffect, useState, useCallback } from "react";
import clsx from "clsx";

type Props = {
  value?: "admin" | "sponsor";
  onChange?: (r: "admin" | "sponsor") => void;
  className?: string;
};

export default function RoleSwitch({ value="admin", onChange, className }: Props){
  const [role, setRole] = useState<"admin"|"sponsor">(value);
  const onChangeCb = useCallback((r: "admin"|"sponsor") => { onChange?.(r); }, [onChange]);

  useEffect(() => { onChangeCb(role); }, [role, onChangeCb]);

  return (
    <div className={clsx("pill lumen w-[360px] h-14 p-1 flex items-center gap-1", className)}>
      <button
        className={clsx(
          "flex-1 h-12 rounded-[12px] transition",
          role === "admin" ? "bg-[var(--accent)] text-white shadow-[var(--halo)]" : "text-[var(--text)] hover:bg-[var(--surface)]"
        )}
        onClick={() => setRole("admin")}
      >
        Admin
      </button>
      <button
        className={clsx(
          "flex-1 h-12 rounded-[12px] transition",
          role === "sponsor" ? "bg-[var(--accent)] text-white shadow-[var(--halo)]" : "text-[var(--text)] hover:bg-[var(--surface)]"
        )}
        onClick={() => setRole("sponsor")}
      >
        Patrocinador
      </button>
    </div>
  );
}
TSX

# --- 3) ClientShell: adiciona respiro horizontal padrão ---
cat > components/ClientShell.tsx <<'TSX'
"use client";

import { ReactNode, useEffect } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import { readSession, setThemeAttr } from "@/components/lib/session";

export default function ClientShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const { role } = readSession();

  useEffect(() => {
    // null => respeita preferência salva/tema do papel
    setThemeAttr(null, role);
  }, [role]);

  const isAuth = pathname === "/login" || pathname === "/forgot-password";

  if (isAuth) return <>{children}</>;

  return (
    <>
      <Topbar />
      <main className="min-h-[70vh]">
        <div className="mx-auto max-w-screen-2xl px-4 md:px-6 py-6">
          {children}
        </div>
      </main>
    </>
  );
}
TSX

echo "== Build =="
pnpm build
