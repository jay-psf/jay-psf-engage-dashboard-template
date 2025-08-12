set -euo pipefail

echo "== Patch 15: Sponsor com layout do Admin + logo 2.5x =="

# 1) Topbar: aumenta o logo do sponsor e mantém só o ícone
apply_topbar() {
  cat > components/ui/Topbar.tsx <<'TSX'
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
TSX
}

# 2) Páginas de Sponsor: alinhar header/sections ao estilo do Admin
apply_sponsor_pages() {
  for p in overview results financials events assets; do
    mkdir -p "app/sponsor/[brand]/$p"
  done

  # Overview já existe com KPIs – mantemos, só garantimos mesmas classes (space-y-6 etc.)
  cat > app/sponsor/[brand]/overview/page.tsx <<'TSX'
import KPI from "@/components/ui/KPI";

export default function Page({ params }: { params: { brand: string } }) {
  const brand = params.brand;
  return (
    <div className="space-y-6">
      <header className="flex items-end justify-between">
        <div>
          <h1 className="text-2xl font-semibold capitalize">{brand} • Overview</h1>
          <p className="text-muted text-sm mt-1">Performance e status do contrato.</p>
        </div>
      </header>

      <section className="kpi-grid">
        <KPI label="Impressões" value="12,4M" delta={14.2} goodIsUp series={[6,7,7,8,9,9,10,11,11,12,12,12.4].map(n=>n*1000)} />
        <KPI label="Engajamento" value="3,9%" delta={0.9} goodIsUp series={[2.7,3.0,3.1,3.3,3.6,3.7,3.8,3.9]} />
        <KPI label="Ativações" value={184} delta={-2.1} goodIsUp={true} series={[120,130,140,150,160,170,180,184]} />
        <KPI label="ROI estimado" value="2,7x" delta={0.4} goodIsUp series={[1.8,1.9,2.0,2.1,2.2,2.4,2.5,2.7]} />
      </section>

      <section className="grid gap-4 grid-cols-1 lg:grid-cols-2">
        <div className="card">
          <h3 className="text-base font-medium mb-2">Eventos ativos</h3>
          <p className="text-muted text-sm">Links rápidos para relatórios por evento.</p>
        </div>
        <div className="card">
          <h3 className="text-base font-medium mb-2">Resultados recentes</h3>
          <p className="text-muted text-sm">Resumo de mídia, alcance e conversões.</p>
        </div>
      </section>
    </div>
  );
}
TSX

  # Demais seções, todas com o mesmo cabeçalho/containers do admin
  cat > app/sponsor/[brand]/results/page.tsx <<'TSX'
export default function Page({ params }: { params: { brand: string } }) {
  const brand = params.brand;
  return (
    <div className="space-y-6">
      <header className="flex items-end justify-between">
        <div>
          <h1 className="text-2xl font-semibold capitalize">{brand} • Resultados</h1>
          <p className="text-muted text-sm mt-1">Indicadores de performance e mídia.</p>
        </div>
      </header>

      <section className="grid gap-4 grid-cols-1 lg:grid-cols-2 xl:grid-cols-3">
        <div className="card"><h3 className="text-base font-medium mb-2">Alcance</h3><p className="text-muted text-sm">Resumo por campanha.</p></div>
        <div className="card"><h3 className="text-base font-medium mb-2">Conversões</h3><p className="text-muted text-sm">Taxas e funis.</p></div>
        <div className="card"><h3 className="text-base font-medium mb-2">Brand lift</h3><p className="text-muted text-sm">Awareness, recall etc.</p></div>
      </section>
    </div>
  );
}
TSX

  cat > app/sponsor/[brand]/financials/page.tsx <<'TSX'
export default function Page({ params }: { params: { brand: string } }) {
  const brand = params.brand;
  return (
    <div className="space-y-6">
      <header className="flex items-end justify-between">
        <div>
          <h1 className="text-2xl font-semibold capitalize">{brand} • Financeiro</h1>
          <p className="text-muted text-sm mt-1">Faturamento, custos e repasses.</p>
        </div>
      </header>

      <section className="grid gap-4 grid-cols-1 lg:grid-cols-2">
        <div className="card"><h3 className="text-base font-medium mb-2">Projeção</h3><p className="text-muted text-sm">Receita prevista vs. realizada.</p></div>
        <div className="card"><h3 className="text-base font-medium mb-2">Extratos</h3><p className="text-muted text-sm">Pagamentos e notas.</p></div>
      </section>
    </div>
  );
}
TSX

  cat > app/sponsor/[brand]/events/page.tsx <<'TSX'
export default function Page({ params }: { params: { brand: string } }) {
  const brand = params.brand;
  return (
    <div className="space-y-6">
      <header className="flex items-end justify-between">
        <div>
          <h1 className="text-2xl font-semibold capitalize">{brand} • Eventos</h1>
          <p className="text-muted text-sm mt-1">Calendário e execução.</p>
        </div>
      </header>

      <section className="grid gap-4 grid-cols-1 lg:grid-cols-2 xl:grid-cols-3">
        <div className="card"><h3 className="text-base font-medium mb-2">Calendário</h3><p className="text-muted text-sm">Próximas ativações.</p></div>
        <div className="card"><h3 className="text-base font-medium mb-2">Checklists</h3><p className="text-muted text-sm">Pendências por evento.</p></div>
        <div className="card"><h3 className="text-base font-medium mb-2">Métricas</h3><p className="text-muted text-sm">KPI por evento.</p></div>
      </section>
    </div>
  );
}
TSX

  cat > app/sponsor/[brand]/assets/page.tsx <<'TSX'
export default function Page({ params }: { params: { brand: string } }) {
  const brand = params.brand;
  return (
    <div className="space-y-6">
      <header className="flex items-end justify-between">
        <div>
          <h1 className="text-2xl font-semibold capitalize">{brand} • Assets</h1>
          <p className="text-muted text-sm mt-1">Arquivos, logos e guias de marca.</p>
        </div>
      </header>

      <section className="grid gap-4 grid-cols-1 lg:grid-cols-2">
        <div className="card"><h3 className="text-base font-medium mb-2">Logos</h3><p className="text-muted text-sm">Pacotes PNG/SVG.</p></div>
        <div className="card"><h3 className="text-base font-medium mb-2">Materiais</h3><p className="text-muted text-sm">Key visuals e templates.</p></div>
      </section>
    </div>
  );
}
TSX
}

# 3) (opcional) Ajuste fino do contraste no dark se ainda houver branco
apply_tokens() {
  sed -i 's/--card: .*;/--card: #0B0E14;/' styles/tokens.css || true
  sed -i 's/--surface: .*;/--surface: #0A0C11;/' styles/tokens.css || true
}

apply_topbar
apply_sponsor_pages
apply_tokens

echo "== Build =="
pnpm build

echo "== Patch 15 aplicado! =="
