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

      <section className="grid gap-4 responsive-grid">
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
