set -euo pipefail
echo "== Patch 25: Sponsor com top-menu e logo 2.5x =="

# Topbar: menu também para sponsor e logo maior
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import { usePathname } from "next/navigation";

function brandLogo(brand?: string){
  const b = (brand || "heineken").toLowerCase();
  return `/logos/${b}.png`;
}

export default function Topbar(){
  const pathname = usePathname();

  const isSponsor = pathname?.startsWith("/sponsor/");
  const brand = isSponsor ? pathname.split("/")[2] : undefined;

  const base = isSponsor ? `/sponsor/${brand}` : "";
  const nav = isSponsor
    ? [
        { href: `${base}/overview`,   label: "Overview" },
        { href: `${base}/events`,     label: "Eventos" },
        { href: `${base}/results`,    label: "Resultados" },
        { href: `${base}/financials`, label: "Financeiro" },
        { href: `${base}/assets`,     label: "Assets" },
        { href: `${base}/settings`,   label: "Settings" },
      ]
    : [
        { href: "/overview", label: "Overview" },
        { href: "/pipeline", label: "Pipeline" },
        { href: "/projetos", label: "Projetos" },
        { href: "/settings", label: "Settings" },
      ];

  const logout = async () => {
    try { await fetch("/api/logout", { method:"POST" }); }
    finally { window.location.href = "/login"; }
  };

  return (
    <header className="sticky top-0 z-40 bg-[var(--bg)]/75 backdrop-blur border-b border-[var(--borderC)]">
      <div className="mx-auto max-w-screen-2xl px-4 h-14 flex items-center gap-4">
        <a href="/" className="font-semibold">Engage</a>

        <nav className="hidden md:flex items-center gap-2">
          {nav.map(i=>{
            const active = pathname?.startsWith(i.href);
            return (
              <a key={i.href} href={i.href}
                 className={`px-3 h-9 rounded-full flex items-center ${active ? "bg-[var(--surface)]" : "hover:bg-[var(--surface)]"}`}>
                {i.label}
              </a>
            );
          })}
        </nav>

        <div className="ml-auto flex items-center gap-3">
          {isSponsor && (
            <div className="h-8 rounded-full px-2 bg-[var(--surface)] border border-[var(--borderC)] flex items-center">
              <Image
                src={brandLogo(brand)} alt={brand||"brand"}
                width={48} height={24} className="rounded-md object-contain"
              />
            </div>
          )}
          <button onClick={logout} className="btn btn-outline">Sair</button>
        </div>
      </div>
    </header>
  );
}
TSX

# Oculta subnav duplicado em páginas sponsor (barra secundária)
# (Cria util global simples; se existir subnav, respeitar data-hide-subnav)
mkdir -p styles
if ! grep -q ".subnav-hidden" styles/globals.css 2>/dev/null; then
cat >> styles/globals.css <<'CSS'

/* Utilitário para esconder subnav duplicado no sponsor */
.subnav-hidden{ display:none !important; }
CSS
fi

echo "== Build =="
pnpm -s build
