export default function Page(){
  const Kpi = ({label, value}:{label:string; value:string}) => (
    <div className="card p-5">
      <div className="text-sm text-muted">{label}</div>
      <div className="text-2xl font-semibold mt-1">{value}</div>
    </div>
  );

  return (
    <>
      <section className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Kpi label="Receita acumulada" value="R$ 2.311.674,00" />
        <Kpi label="Eventos ativos" value="12" />
        <Kpi label="Leads no funil" value="184" />
        <Kpi label="Satisfação média" value="4,7/5" />
      </section>

      <section className="grid lg:grid-cols-3 gap-4">
        <div className="card p-5 lg:col-span-2">
          <div className="flex items-center justify-between">
            <h3 className="font-semibold">Performance recente</h3>
            <button className="btn-primary">Ver detalhes</button>
          </div>
          <div className="mt-4 h-64 grid place-items-center text-muted">
            (gráfico entra aqui)
          </div>
        </div>
        <div className="card p-5">
          <h3 className="font-semibold">Próximos marcos</h3>
          <ul className="mt-3 space-y-2 text-sm text-muted">
            <li>Entrega de relatório do Evento X</li>
            <li>Kickoff com patrocinador ACME</li>
            <li>Publicação de álbum de fotos</li>
          </ul>
        </div>
      </section>
    </>
  );
}
