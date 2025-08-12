export default function Page() {
  const Kpi = ({ title, value }: { title: string; value: string }) => (
    <div className="rounded-2xl border border-[var(--border)] bg-card p-5 shadow-soft">
      <p className="text-[12px] uppercase tracking-wide text-[var(--muted)]">{title}</p>
      <p className="mt-2 text-[26px] font-bold">{value}</p>
    </div>
  );

  return (
    <div className="space-y-6">
      <section className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
        <Kpi title="Receita acumulada" value="R$ 2.311.674,00" />
        <Kpi title="Eventos ativos" value="12" />
        <Kpi title="Leads no funil" value="184" />
        <Kpi title="Satisfação média" value="4,7/5" />
      </section>

      <section className="grid grid-cols-1 gap-4 xl:grid-cols-3">
        <div className="rounded-2xl border border-[var(--border)] bg-card p-5 shadow-soft xl:col-span-2">
          <div className="mb-4 flex items-center justify-between">
            <h3 className="text-[15px] font-semibold">Performance recente</h3>
            <button className="rounded-full border border-[var(--border)] px-3 py-1.5 text-[13px] hover:bg-cardghost">
              Ver detalhes
            </button>
          </div>
          <div className="h-[300px] rounded-xl border border-dashed border-[var(--border)] bg-cardghost/40" />
        </div>

        <div className="rounded-2xl border border-[var(--border)] bg-card p-5 shadow-soft">
          <h3 className="mb-3 text-[15px] font-semibold">Próximos marcos</h3>
          <ul className="space-y-2 text-[14px] text-[var(--text)]/90">
            <li>Entrega de relatório do Evento X</li>
            <li>Kickoff com patrocinador ACME</li>
            <li>Publicação de álbum de fotos</li>
          </ul>
        </div>
      </section>
    </div>
  );
}
