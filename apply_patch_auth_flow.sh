set -euo pipefail

echo "== 1) Tipos compartilhados =="
mkdir -p components/lib
cat > components/lib/types.ts <<'TS'
export type Role = "admin" | "sponsor";
export type Session = { role?: Role; brand?: string; username?: string };
TS

echo "== 2) ClientShell (esconde chrome no /login e aplica tema) =="
mkdir -p components
cat > components/ClientShell.tsx <<'TSX'
"use client";
import { useEffect } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import Sidebar from "@/components/ui/Sidebar";
import type { Role } from "@/components/lib/types";

type Props = {
  children: React.ReactNode;
  role: Role | undefined;
  brand?: string;
};

export default function ClientShell({ children, role, brand }: Props) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";

  // Aplica tema: sponsor = dark, admin = light
  useEffect(() => {
    const html = document.documentElement;
    if (role === "sponsor") html.setAttribute("data-theme", "dark");
    else html.removeAttribute("data-theme");
  }, [role]);

  if (isLogin) {
    // Tela de login sem chrome
    return <main className="min-h-screen grid place-items-center px-4">{children}</main>;
  }

  // App shell completo
  return (
    <>
      <Topbar role={role} brand={brand} />
      <div className="mx-auto grid max-w-screen-2xl grid-cols-[260px,1fr] gap-6 p-6">
        <Sidebar role={role} />
        <main className="min-h-[70vh] animate-[fadeIn_.3s_ease]">{children}</main>
      </div>
      <style>{`@keyframes fadeIn{from{opacity:.01;transform:translateY(6px)}to{opacity:1;transform:none}}`}</style>
    </>
  );
}
TSX

echo "== 3) Root layout server-side (lê cookies e injeta no ClientShell) =="
mkdir -p app
cat > app/layout.tsx <<'TSX'
import "./styles/globals.css";
import "./styles/tokens.css";
import { cookies } from "next/headers";
import ClientShell from "@/components/ClientShell";
import type { Role } from "@/components/lib/types";

export const metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const role = (cookies().get("role")?.value as Role | undefined) ?? undefined;
  const brand = cookies().get("brand")?.value;

  return (
    <html lang="pt-BR">
      <body className="min-h-screen bg-[var(--bg)] text-[var(--text)]">
        <ClientShell role={role} brand={brand}>{children}</ClientShell>
      </body>
    </html>
  );
}
TSX

echo "== 4) Topbar com Sair e avatar -> /settings =="
mkdir -p components/ui
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import Link from "next/link";
import { useState } from "react";
import type { Role } from "@/components/lib/types";

export default function Topbar({ role, brand }: { role?: Role; brand?: string }) {
  const isSponsor = role === "sponsor";
  async function logout() {
    await fetch("/api/logout", { method: "POST" });
    window.location.href = "/login";
  }
  return (
    <header className="sticky top-0 z-40 border-b border-border bg-[var(--card)]/85 backdrop-blur">
      <div className="mx-auto flex max-w-screen-2xl items-center justify-between px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="h-8 w-8 rounded-xl bg-accent/15 grid place-items-center font-semibold text-sm text-[var(--text)]">E</div>
          <span className="font-semibold">Engage</span>
        </div>
        <div className="flex items-center gap-3">
          {isSponsor && (
            <div className="h-8 w-auto flex items-center gap-2 px-2 rounded-lg border border-border bg-[var(--surface)]">
              <Image
                src={`/logos/${brand ?? "acme"}.png`}
                alt={brand ?? "brand"}
                width={24}
                height={24}
              />
              <span className="text-sm">{brand ?? "Sponsor"}</span>
            </div>
          )}
          <Link href="/settings" className="h-9 w-9 overflow-hidden rounded-full border border-border bg-[var(--surface)]">
            <Image src="/avatar-placeholder.png" alt="Perfil" width={36} height={36} />
          </Link>
          <button onClick={logout} className="px-3 py-1.5 rounded-xl border border-border bg-accent text-white font-medium shadow-soft">
            Sair
          </button>
        </div>
      </div>
    </header>
  );
}
TSX

echo "== 5) Sidebar RBAC (admin vê tudo, sponsor só /sponsor) =="
cat > components/ui/Sidebar.tsx <<'TSX'
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
TSX

echo "== 6) Página Settings (stub) =="
mkdir -p app/settings
cat > app/settings/page.tsx <<'TSX'
export const metadata = { title: "Settings • Engage" };
export default function SettingsPage() {
  return (
    <section className="rounded-2xl border border-border bg-card p-6 shadow-soft">
      <h1 className="text-xl font-semibold">Dados da Empresa</h1>
      <p className="mt-2 text-sm text-muted">Configure nome, CNPJ, e-mail e telefone.</p>
      <form className="mt-6 grid gap-4 md:grid-cols-2">
        <label className="block">
          <div className="text-sm mb-1">Nome</div>
          <input className="input rounded-xl" placeholder="Ex.: Heineken Brasil" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">CNPJ</div>
          <input className="input rounded-xl" placeholder="00.000.000/0000-00" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">E-mail</div>
          <input className="input rounded-xl" placeholder="contato@empresa.com" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">Telefone</div>
          <input className="input rounded-xl" placeholder="(11) 99999-9999" />
        </label>
        <div className="md:col-span-2">
          <button type="button" className="px-5 py-2.5 rounded-xl bg-accent text-white shadow-soft">Salvar</button>
        </div>
      </form>
    </section>
  );
}
TSX

echo "== 7) CSS helper de inputs (se não existir) e avatar placeholder =="
mkdir -p public
[ -f public/avatar-placeholder.png ] || curl -fsSL https://dummyimage.com/72x72/eee/aaa.png&text=%20 -o public/avatar-placeholder.png || true

mkdir -p styles
# acrescenta utilitário .input se não existir
grep -q ".input {" styles/tokens.css 2>/dev/null || cat >> styles/tokens.css <<'CSS'

/* Inputs util */
.input {
  height: 44px;
  width: 100%;
  border: 1px solid var(--borderC, rgba(16,24,40,0.10));
  background: var(--surface, #F9FBFF);
  padding: 0 12px;
}
CSS

echo "== 8) Garantir logo heineken demo =="
mkdir -p public/logos
[ -f public/logos/heineken.png ] || [ -f public/logos/heineken.jpg ] || [ -f public/logos/Heineken-logo.jpeg ] && cp -f public/logos/Heineken-logo.jpeg public/logos/heineken.png || true

echo "== 9) Build =="
pnpm build

echo "== Patch aplicado! =="
