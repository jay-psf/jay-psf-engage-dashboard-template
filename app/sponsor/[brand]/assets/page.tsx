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

      <section className="grid gap-4 responsive-grid">
        <div className="card"><h3 className="text-base font-medium mb-2">Logos</h3><p className="text-muted text-sm">Pacotes PNG/SVG.</p></div>
        <div className="card"><h3 className="text-base font-medium mb-2">Materiais</h3><p className="text-muted text-sm">Key visuals e templates.</p></div>
      </section>
    </div>
  );
}
