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

      <section className="grid gap-4 responsive-grid xl:grid-cols-3">
        <div className="card"><h3 className="text-base font-medium mb-2">Calendário</h3><p className="text-muted text-sm">Próximas ativações.</p></div>
        <div className="card"><h3 className="text-base font-medium mb-2">Checklists</h3><p className="text-muted text-sm">Pendências por evento.</p></div>
        <div className="card"><h3 className="text-base font-medium mb-2">Métricas</h3><p className="text-muted text-sm">KPI por evento.</p></div>
      </section>
    </div>
  );
}
