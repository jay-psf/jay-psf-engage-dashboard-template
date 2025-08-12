set -euo pipefail

echo "== Patch 21: Sponsor com top-nav como Admin (sem sidebar) =="

# 1) Topbar: inclui navegação horizontal por perfil (admin/sponsor) e realce do link ativo.
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
        "h-9 px-3 rounded-full border",
        active
          ? "bg-[var(--accent)] text-white border-transparent"
          : "bg-[var(--card)] text-[var(--text)] border-border hover:shadow-[0_0_0_6px_var(--ring)] hover:-translate-y-[1px]",
        "transition inline-flex items-center"
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
    try { await fetch("/api/logout", { method: "POST" }); } catch {}
    window.location.href = "/login";
  };

  const showBrand = isSponsor && brand;

  return (
    <header className="sticky top-0 z-30 bg-[var(--bg)]/85 backdrop-blur border-b border-border">
      <div className="mx-auto max-w-screen-2xl flex items-center justify-between gap-3 px-4 py-3">
        {/* Logo + nome do produto */}
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-[var(--card)] grid place-items-center border border-border">
            <span className="text-sm font-semibold">E</span>
          </div>
          <span className="font-semibold">Engage</span>
        </div>

        {/* Navegação em abas (muda por perfil) */}
        <nav className="hidden md:flex items-center gap-2">
          {(isSponsor ? sponsorNav : adminNav).map((i) => (
            <NavLink key={i.href} href={i.href} active={i.active}>{i.label}</NavLink>
          ))}
        </nav>

        {/* Ações à direita: logo do sponsor + sair */}
        <div className="flex items-center gap-2">
          {showBrand && (
            <span className="inline-flex items-center h-10 rounded-full border border-border bg-[var(--card)] px-3">
              <Image
                alt={brand!}
                src={`/logos/${brandSlug}.png`}
                width={50} height={50}   /* ~2.5x do 20px antigo */
                style={{ borderRadius: 8, display: "block" }}
              />
            </span>
          )}
          <button onClick={onLogout} className="btn btn-outline">Sair</button>
        </div>
      </div>

      {/* Navegação responsiva (mobile) */}
      <div className="md:hidden border-t border-border px-4 py-2 flex flex-wrap gap-6">
        {(isSponsor ? sponsorNav : adminNav).map((i) => (
          <Link
            key={i.href}
            href={i.href}
            className={[
              "text-sm",
              i.active ? "text-[var(--accent)] font-semibold" : "opacity-80 hover:opacity-100"
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

# 2) ClientShell: remove grid com Sidebar e usa coluna única (Topbar + container)
cat > components/ClientShell.tsx <<'TSX'
"use client";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import { readSession } from "@/components/lib/session";

export default function ClientShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";
  const { role } = readSession();

  // tema automático por papel quando for "system" (mantém como estava)
  if (typeof window !== "undefined") {
    const pref = localStorage.getItem("theme-pref");
    const html = document.documentElement;
    if (pref === "light" || pref === "dark") {
      html.setAttribute("data-theme", pref);
    } else {
      const sys = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
      html.setAttribute("data-theme", role === "sponsor" ? "dark" : sys);
    }
  }

  if (isLogin) return <>{children}</>;

  return (
    <>
      <Topbar />
      <div className="mx-auto max-w-screen-2xl px-4 py-6">
        <main className="min-h-[70vh] animate-[fadeIn_.3s_ease]">{children}</main>
      </div>
    </>
  );
}
TSX

# 3) (Opcional) Sidebar: mantém arquivo mas vira "no-op" para evitar imports antigos
cat > components/ui/Sidebar.tsx <<'TSX'
export default function Sidebar(){ return null; }
TSX

# 4) Build
echo "== Build =="
pnpm build

echo
echo "✅ Patch 21 aplicado. Sponsor agora usa top-nav como Admin."
