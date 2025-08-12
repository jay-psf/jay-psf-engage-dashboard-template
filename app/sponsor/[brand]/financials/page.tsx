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

      <section className="grid gap-4 responsive-grid">
        <div className="card"><h3 className="text-base font-medium mb-2">Projeção</h3><p className="text-muted text-sm">Receita prevista vs. realizada.</p></div>
        <div className="card"><h3 className="text-base font-medium mb-2">Extratos</h3><p className="text-muted text-sm">Pagamentos e notas.</p></div>
      </section>
    </div>
  );
}
