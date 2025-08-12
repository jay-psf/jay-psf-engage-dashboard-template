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
