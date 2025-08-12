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
