"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { readSession } from "@/components/lib/session";

function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
  const pathname = usePathname();
  const active = pathname === href;
  return (
    <Link
      href={href}
      className={
        "rounded-xl px-3 py-2 text-sm transition-colors " +
        (active
          ? "bg-[var(--surface)] text-[var(--text)]"
          : "text-[var(--muted)] hover:text-[var(--text)] hover:bg-[var(--surface)]")
      }
    >
      {children}
    </Link>
  );
}

export default function Topbar() {
  const { role, brand } = readSession();
  const brandLogo = brand ? `/logos/${brand}.png` : undefined;

  return (
    <header className="sticky top-0 z-40 border-b border-[var(--borderC)] bg-[var(--bg)]/90 backdrop-blur">
      <div className="mx-auto flex h-16 max-w-screen-2xl items-center justify-between px-4">
        <div className="flex items-center gap-3">
          <Link href={role === "sponsor" && brand ? `/sponsor/${brand}/overview` : "/"} className="text-base font-semibold">
            Engage
          </Link>

          {/* Navegação primária */}
          {role === "admin" ? (
            <nav className="ml-2 hidden gap-1 md:flex">
              <NavLink href="/">Overview</NavLink>
              <NavLink href="/pipeline">Pipeline</NavLink>
              <NavLink href="/projetos">Projetos</NavLink>
              <NavLink href="/settings">Settings</NavLink>
            </nav>
          ) : role === "sponsor" && brand ? (
            <nav className="ml-2 hidden gap-1 md:flex">
              <NavLink href={`/sponsor/${brand}/overview`}>Overview</NavLink>
              <NavLink href={`/sponsor/${brand}/results`}>Resultados</NavLink>
              <NavLink href={`/sponsor/${brand}/financials`}>Financeiro</NavLink>
              <NavLink href={`/sponsor/${brand}/events`}>Eventos</NavLink>
              <NavLink href={`/sponsor/${brand}/assets`}>Assets</NavLink>
              <NavLink href={`/sponsor/${brand}/settings`}>Settings</NavLink>
            </nav>
          ) : null}
        </div>

        {/* Lado direito: chip de perfil (só logo para sponsor) + logout */}
        <div className="flex items-center gap-3">
          {role === "sponsor" && brandLogo ? (
            <Link
              href={`/sponsor/${brand}/settings`}
              className="flex items-center gap-2 rounded-full border border-[var(--borderC)] bg-[var(--card)] px-2 py-1 shadow-soft"
              title="Configurações"
            >
              <img
                src={brandLogo}
                alt={brand ?? "brand"}
                width="50"
                height="50"
                style={{ display: "block", borderRadius: 10 }}
              />
            </Link>
          ) : (
            <Link
              href="/settings"
              className="rounded-full border border-[var(--borderC)] bg-[var(--card)] px-3 py-1.5 text-sm shadow-soft"
            >
              Perfil
            </Link>
          )}

          <form method="post" action="/api/logout" className="hidden md:block">
            <button
              className="rounded-xl border border-[var(--borderC)] bg-[var(--surface)] px-3 py-1.5 text-sm hover:shadow-soft transition"
            >
              Sair
            </button>
          </form>
        </div>
      </div>
    </header>
  );
}
