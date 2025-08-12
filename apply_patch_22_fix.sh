set -euo pipefail
echo "== Patch 22 (fix): corrige Topbar e recompila =="

cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { readSession } from "@/components/lib/session";

function NavLink({
  href, active, children,
}: { href: string; active: boolean; children: React.ReactNode }) {
  return (
    <Link
      href={href}
      className={[
        "h-9 px-3 rounded-full border transition inline-flex items-center",
        active
          ? "bg-[var(--accent)] text-white border-transparent"
          : "bg-[var(--card)] text-[var(--text)] border-border hover:shadow-[0_0_0_12px_var(--ring-strong)] hover:-translate-y-[1px] hover:scale-[1.02]",
      ].join(" ")}
    >
      {children}
    </Link>
  );
}

export default function Topbar() {
  const { role, brand } = readSession();
  const pathname = usePathname();
  const isSponsor = role === "sponsor";
  const brandSlug = (brand || "acme").toLowerCase();

  const adminNav = [
    { href: "/", label: "Overview", active: pathname === "/" },
    { href: "/pipeline", label: "Pipeline", active: pathname === "/pipeline" },
    { href: "/projetos", label: "Projetos", active: pathname === "/projetos" },
    { href: "/settings", label: "Settings", active: pathname === "/settings" },
  ];

  const sBase = `/sponsor/${brandSlug}`;
  const sponsorNav = [
    { href: `${sBase}/overview`,   label: "Overview",   active: pathname.startsWith(`${sBase}/overview`) },
    { href: `${sBase}/results`,    label: "Resultados", active: pathname.startsWith(`${sBase}/results`) },
    { href: `${sBase}/financials`, label: "Financeiro", active: pathname.startsWith(`${sBase}/financials`) },
    { href: `${sBase}/events`,     label: "Eventos",    active: pathname.startsWith(`${sBase}/events`) },
    { href: `${sBase}/assets`,     label: "Assets",     active: pathname.startsWith(`${sBase}/assets`) },
    { href: `${sBase}/settings`,   label: "Settings",   active: pathname.startsWith(`${sBase}/settings`) },
  ];

  const onLogout = async () => {
    try { await fetch("/api/logout", { method: "POST" }); }
    finally { window.location.href = "/login"; }
  };

  return (
    <header className="sticky top-0 z-30 bg-[var(--bg)]/85 backdrop-blur border-b border-border">
      <div className="mx-auto max-w-screen-2xl flex items-center justify-between gap-3 px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-[var(--card)] grid place-items-center border border-border">
            <span className="text-sm font-semibold">E</span>
          </div>
          <span className="font-semibold">Engage</span>
        </div>

        <nav className="hidden md:flex items-center gap-2">
          {(isSponsor ? sponsorNav : adminNav).map((i) => (
            <NavLink key={i.href} href={i.href} active={i.active}>
              {i.label}
            </NavLink>
          ))}
        </nav>

        <div className="flex items-center gap-3">
          {isSponsor && brand && (
            <span className="inline-flex items-center h-12 rounded-xl border border-border bg-[var(--card)] px-3">
              <Image
                alt={brand}
                src={`/logos/${brandSlug}.png`}
                width={100}
                height={40}
                style={{ display: "block", objectFit: "contain", borderRadius: 10 }}
                priority
              />
            </span>
          )}
          <button onClick={onLogout} className="btn btn-outline">Sair</button>
        </div>
      </div>

      <div className="md:hidden border-t border-border px-4 py-2 flex flex-wrap gap-6">
        {(isSponsor ? sponsorNav : adminNav).map((i) => (
          <Link
            key={i.href}
            href={i.href}
            className={[
              "text-sm",
              i.active ? "text-[var(--accent)] font-semibold" : "opacity-80 hover:opacity-100",
            ].join(" ")}
          >
            {i.label}
          </Link>
        ))}
      </div>
    </header>
  );
}
TSX

echo "== Build =="
pnpm build
echo "✅ Patch 22 (fix) aplicado."
