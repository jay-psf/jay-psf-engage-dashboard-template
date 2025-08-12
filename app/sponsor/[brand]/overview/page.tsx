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
