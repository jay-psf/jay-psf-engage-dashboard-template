set -euo pipefail

echo "== Patch 14: KPIs com sparkline + overview admin/sponsor =="

# 1) Componente KPI (sem dependências)
mkdir -p components/ui
cat > components/ui/KPI.tsx <<'TSX'
type Props = {
  label: string;
  value: string | number;
  delta?: number;         // ex: +12.3 ou -4.1 (em %)
  goodIsUp?: boolean;     // default: true (se false, queda é bom)
  series?: number[];      // sparkline
};
function toFixedSmart(n: number) {
  const a = Math.abs(n);
  if (a >= 100) return n.toFixed(0);
  if (a >= 10)  return n.toFixed(1);
  return n.toFixed(2);
}
export default function KPI({ label, value, delta, goodIsUp = true, series }: Props) {
  // sparkline simples
  let path = "";
  if (series && series.length > 1) {
    const w = 100, h = 28;
    const min = Math.min(...series), max = Math.max(...series);
    const span = max - min || 1;
    const stepX = w / (series.length - 1);
    path = series
      .map((v, i) => {
        const x = i * stepX;
        const y = h - ((v - min) / span) * h;
        return `${i === 0 ? "M" : "L"}${x},${y}`;
      })
      .join(" ");
  }
  const isUp = delta !== undefined ? delta >= 0 : undefined;
  const good = isUp === undefined ? undefined : (isUp ? goodIsUp : !goodIsUp);
  return (
    <div className="kpi">
      <div className="kpi-label">{label}</div>
      <div className="kpi-value">{value}</div>
      <div className="flex items-center justify-between">
        <div className="kpi-trend">
          {delta !== undefined ? (
            <>
              <span aria-hidden="true">{isUp ? "↑" : "↓"}</span>
              <span className={good === undefined ? "" : (good ? "badge-pos" : "badge-neg")}>
                {toFixedSmart(delta)}%
              </span>
              <span className="text-muted"> vs. mês ant.</span>
            </>
          ) : (
            <span className="text-muted">—</span>
          )}
        </div>
        {path ? (
          <svg width="100" height="28" viewBox="0 0 100 28" fill="none" aria-hidden="true">
            <path d={path} stroke="currentColor" strokeWidth="2" opacity="0.9"/>
          </svg>
        ) : <span className="text-muted text-xs">sem dados</span>}
      </div>
    </div>
  );
}
TSX

# 2) Overview ADMIN (usa KPIs + cards)
cat > app/admin/page.tsx <<'TSX'
import KPI from "@/components/ui/KPI";

export default function Page() {
  return (
    <div className="space-y-6">
      <header className="flex items-end justify-between">
        <div>
          <h1 className="text-2xl font-semibold">Overview • Admin</h1>
          <p className="text-muted text-sm mt-1">Visão geral dos resultados e operações.</p>
        </div>
      </header>

      <section className="kpi-grid">
        <KPI label="Receita acumulada" value="R$ 2,4M" delta={12.4} goodIsUp series={[18,22,19,25,28,30,33,35,42,44,48,52]}/>
        <KPI label="Eventos ativos" value={34} delta={-4.2} goodIsUp={false} series={[12,9,11,10,8,7,6,6,5,5,4,4]}/>
        <KPI label="Conversões no funil" value="3,1%" delta={0.8} goodIsUp series={[2.1,2.2,2.0,2.4,2.5,2.6,2.7,2.9,3.0,3.1,3.1,3.1]}/>
        <KPI label="Satisfação média" value="4,6/5" delta={1.2} goodIsUp series={[4.1,4.0,4.2,4.3,4.3,4.4,4.5,4.6,4.5,4.6,4.6,4.6]}/>
      </section>

      <section className="grid gap-4 grid-cols-1 lg:grid-cols-2">
        <div className="card">
          <h3 className="text-base font-medium mb-2">Últimos contratos</h3>
          <p className="text-muted text-sm">Resumo dos 10 mais recentes por valor e status.</p>
        </div>
        <div className="card">
          <h3 className="text-base font-medium mb-2">Alertas e pendências</h3>
          <p className="text-muted text-sm">Nada crítico no momento. 3 itens aguardando revisão.</p>
        </div>
      </section>
    </div>
  );
}
TSX

# 3) Overview ROOT "/" também aponta para um overview com KPIs (útil se a home é admin)
cat > app/page.tsx <<'TSX'
import KPI from "@/components/ui/KPI";

export default function Page() {
  return (
    <div className="space-y-6">
      <header className="flex items-end justify-between">
        <div>
          <h1 className="text-2xl font-semibold">Overview</h1>
          <p className="text-muted text-sm mt-1">Atalhos e resumos principais.</p>
        </div>
      </header>

      <section className="kpi-grid">
        <KPI label="Receita (YTD)" value="R$ 1,9M" delta={9.7} goodIsUp series={[15,16,18,19,20,22,23,25,26,28,29,31]}/>
        <KPI label="Patrocinadores ativos" value={12} delta={-3.1} goodIsUp={false} series={[14,14,13,13,12,12,12,12,12,12,12,12]}/>
        <KPI label="Leads qualificados" value={248} delta={5.2} goodIsUp series={[180,190,195,210,215,220,230,235,240,245,246,248]}/>
        <KPI label="NPS" value="71" delta={0.6} goodIsUp series={[66,67,68,69,69,70,70,71,71,71,71,71]}/>
      </section>

      <section className="grid gap-4 grid-cols-1 lg:grid-cols-2">
        <div className="card">
          <h3 className="text-base font-medium mb-2">Atividade recente</h3>
          <p className="text-muted text-sm">Assinaturas, renovações e interações mais recentes.</p>
        </div>
        <div className="card">
          <h3 className="text-base font-medium mb-2">Próximos marcos</h3>
          <p className="text-muted text-sm">3 entregas esta semana, 2 aprovações pendentes.</p>
        </div>
      </section>
    </div>
  );
}
TSX

# 4) Overview SPONSOR escuro com KPIs
mkdir -p app/sponsor/[brand]/overview
cat > app/sponsor/[brand]/overview/page.tsx <<'TSX'
import KPI from "@/components/ui/KPI";

export default function Page({ params }: { params: { brand: string } }) {
  const brand = params.brand;
  return (
    <div className="space-y-6">
      <header className="flex items-end justify-between">
        <div>
          <h1 className="text-2xl font-semibold capitalize">{brand} • Overview</h1>
          <p className="text-muted text-sm mt-1">Performance e status do contrato ativo.</p>
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
          <p className="text-muted text-sm">Detalhes e links para relatórios por evento.</p>
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

echo "== Build =="
pnpm build

echo "== Patch 14 aplicado! =="
