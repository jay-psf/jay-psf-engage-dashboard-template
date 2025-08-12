set -euo pipefail
echo "== Patch 35: Tipografia + Respiro + Overview refinado =="

# 1) TOKENS — escalas de tipo/spacing/raio/sombra
mkdir -p styles
cat > styles/tokens.css <<'CSS'
:root{
  /* Brand */
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;

  /* Light */
  --bg:#F6F8FB; --card:#FFFFFF; --surface:#F2F4F9;
  --text:#0B1524; --muted:#667085; --borderC:rgba(16,24,40,.12);

  /* Dark */
  --bg-dark:#0B1220; --card-dark:#0F1627; --surface-dark:#0C1322;
  --text-dark:#E6E8EC; --muted-dark:#9BA3AF; --borderC-dark:rgba(255,255,255,.10);

  /* Tipografia (modular scale leve) */
  --fs-xs:12px; --fs-sm:13.5px; --fs-md:15px; --fs-lg:17px;
  --fs-h6:18px; --fs-h5:20px; --fs-h4:24px; --fs-h3:28px; --fs-h2:34px; --fs-h1:42px;

  /* Espaços (8-based com sutilezas) */
  --space-1:4px; --space-2:8px; --space-3:12px; --space-4:16px; --space-5:20px;
  --space-6:24px; --space-7:28px; --space-8:32px; --space-10:40px; --space-12:48px;

  /* Container */
  --container: 1200px;

  /* Raio/Sombras */
  --radius:16px; --radius-lg:22px;
  --elev:0 10px 30px rgba(2,32,71,.08);
  --elev-dark:0 14px 36px rgba(0,0,0,.35);
}

:root[data-theme="dark"]{
  --bg:var(--bg-dark); --card:var(--card-dark); --surface:var(--surface-dark);
  --text:var(--text-dark); --muted:var(--muted-dark); --borderC:var(--borderC-dark);
}
CSS

# 2) GLOBALS — utilitários de layout/tipo/tabela/gráfico
cat > styles/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Base */
html,body{ background:var(--bg); color:var(--text); }

/* Tipografia de títulos (consistente em toda a app) */
:where(h1){ font-size:var(--fs-h1); line-height:1.15; letter-spacing:-0.01em; font-weight:700; }
:where(h2){ font-size:var(--fs-h2); line-height:1.18; letter-spacing:-0.01em; font-weight:700; }
:where(h3){ font-size:var(--fs-h3); line-height:1.2;  font-weight:600; }
:where(h4){ font-size:var(--fs-h4); line-height:1.25; font-weight:600; }
:where(h5){ font-size:var(--fs-h5); line-height:1.3;  font-weight:600; }
:where(h6){ font-size:var(--fs-h6); line-height:1.35; font-weight:600; }
:where(p,li,td,th){ font-size:var(--fs-md); }

/* Container de página (respiro e largura) */
.page{
  max-width:var(--container);
  margin: 0 auto;
  padding: var(--space-6) var(--space-6) var(--space-10);
}

/* Seções e cartões */
.section{ margin-bottom: var(--space-10); }
.card{
  background:var(--card);
  border:1px solid var(--borderC);
  border-radius:var(--radius);
  box-shadow: var(--elev);
}
:root[data-theme="dark"] .card{ box-shadow: var(--elev-dark); }
.card-body{ padding: var(--space-6); }
.card-title{ font-size:var(--fs-h5); font-weight:600; margin-bottom: var(--space-3); }

/* Métricas simples */
.kpi{ display:grid; gap:6px; }
.kpi .label{ color:var(--muted); font-size:var(--fs-sm); }
.kpi .value{ font-size:var(--fs-h4); font-weight:700; letter-spacing:-0.01em; }

/* Tabelas elegantes */
.table{
  width:100%;
  border-collapse:separate;
  border-spacing:0;
  background:var(--card);
  border:1px solid var(--borderC);
  border-radius:var(--radius);
  overflow:hidden;
}
.table thead th{
  text-align:left; font-weight:600; font-size:var(--fs-sm);
  color:var(--muted); background:var(--surface);
  padding:12px 16px; border-bottom:1px solid var(--borderC);
  position:sticky; top:0; z-index:1;
}
.table tbody td{ padding:14px 16px; border-bottom:1px solid var(--borderC); }
.table tbody tr:nth-child(odd){ background:color-mix(in oklab, var(--surface) 60%, transparent); }
@supports not (background: color-mix(in oklab, #000 50%, #fff 50%)){
  .table tbody tr:nth-child(odd){ background:var(--surface); }
}
.table tfoot td{ padding:12px 16px; background:var(--surface); }

/* Painel de gráfico */
.chart{
  background:var(--card);
  border:1px solid var(--borderC);
  border-radius:var(--radius);
  padding: var(--space-6);
  box-shadow: var(--elev);
}

/* Inputs e botões básicos (mantém sua implementação atual) */
.input{
  width:100%; height:48px;
  border:1px solid var(--borderC);
  background:var(--surface); color:var(--text);
  border-radius:var(--radius);
  padding:0 14px;
}

/* Utilitário de grid de KPIs */
.kpi-grid{
  display:grid; gap:var(--space-6);
  grid-template-columns: repeat(4, minmax(0,1fr));
}
@media (max-width: 1100px){ .kpi-grid{ grid-template-columns: repeat(2, minmax(0,1fr)); } }
@media (max-width: 640px){ .kpi-grid{ grid-template-columns: 1fr; } }
CSS

# 3) CLIENTSHELL — aplica container de página (tira conteúdo colado na borda)
if test -f components/ClientShell.tsx; then
  perl -0777 -pe 's/<main className="[^"]*">/<main className="page">/s' -i components/ClientShell.tsx || true
fi

# 4) OVERVIEW ADMIN — layout limpo com kpis + tabela mock
mkdir -p app/admin
cat > app/admin/page.tsx <<'TSX'
export default function AdminOverview(){
  return (
    <div className="section">
      <header className="section" style={{marginBottom:"var(--space-6)"}}>
        <h1>Visão geral</h1>
        <p className="text-[var(--muted)]" style={{marginTop:"6px"}}>Resumo operacional e pipeline</p>
      </header>

      <div className="kpi-grid section">
        <div className="card"><div className="card-body kpi"><span className="label">Projetos ativos</span><span className="value">14</span></div></div>
        <div className="card"><div className="card-body kpi"><span className="label">Leads no pipeline</span><span className="value">52</span></div></div>
        <div className="card"><div className="card-body kpi"><span className="label">Conversão</span><span className="value">18%</span></div></div>
        <div className="card"><div className="card-body kpi"><span className="label">Receita (Mês)</span><span className="value">R$ 214k</span></div></div>
      </div>

      <div className="section card">
        <div className="card-body">
          <div className="card-title">Pipeline recente</div>
          <div style={{overflowX:"auto"}}>
            <table className="table">
              <thead><tr><th>Empresa</th><th>Fase</th><th>Owner</th><th>Valor</th></tr></thead>
              <tbody>
                <tr><td>Heineken</td><td>Proposta</td><td>Ana</td><td>R$ 80k</td></tr>
                <tr><td>ACME</td><td>Descoberta</td><td>João</td><td>R$ 25k</td></tr>
                <tr><td>Natura</td><td>Negociação</td><td>Maria</td><td>R$ 60k</td></tr>
                <tr><td>Itaú</td><td>Fechado</td><td>Carlos</td><td>R$ 49k</td></tr>
              </tbody>
              <tfoot><tr><td colSpan={4}>Dados ilustrativos</td></tr></tfoot>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
TSX

# 5) OVERVIEW SPONSOR — mesma linguagem visual
mkdir -p app/sponsor/[brand]/overview
cat > app/sponsor/[brand]/overview/page.tsx <<'TSX'
type Params = { params: { brand: string } }
export default function SponsorOverview({ params }: Params){
  const brand = params.brand;
  return (
    <div className="section">
      <header className="section" style={{marginBottom:"var(--space-6)"}}>
        <h1 className="capitalize">{brand}</h1>
        <p className="text-[var(--muted)]" style={{marginTop:"6px"}}>Resultados e entregas do patrocínio</p>
      </header>

      <div className="kpi-grid section">
        <div className="card"><div className="card-body kpi"><span className="label">Eventos ativos</span><span className="value">6</span></div></div>
        <div className="card"><div className="card-body kpi"><span className="label">Alcance (30d)</span><span className="value">1.2M</span></div></div>
        <div className="card"><div className="card-body kpi"><span className="label">Custo / Evento</span><span className="value">R$ 34k</span></div></div>
        <div className="card"><div className="card-body kpi"><span className="label">Satisfação</span><span className="value">92%</span></div></div>
      </div>

      <div className="section card">
        <div className="card-body">
          <div className="card-title">Resultados recentes</div>
          <div style={{overflowX:"auto"}}>
            <table className="table">
              <thead><tr><th>Evento</th><th>Data</th><th>Alcance</th><th>Engajamento</th></tr></thead>
              <tbody>
                <tr><td>Summer Fest</td><td>12/07</td><td>320k</td><td>7.4%</td></tr>
                <tr><td>Campus Day</td><td>28/06</td><td>210k</td><td>6.1%</td></tr>
                <tr><td>VIP Night</td><td>05/06</td><td>140k</td><td>8.2%</td></tr>
                <tr><td>Run City</td><td>22/05</td><td>530k</td><td>5.0%</td></tr>
              </tbody>
              <tfoot><tr><td colSpan={4}>Dados ilustrativos</td></tr></tfoot>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
TSX

echo "== Build =="
pnpm build
