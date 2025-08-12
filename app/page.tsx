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
