export default function AdminOverview(){
  return (
    <div className="section">
      <header className="section" style={{marginBottom:"var(--space-6)"}}>
        <h1>Visão geral</h1>
        <p className="text-[var(--muted)]" style={{marginTop:"6px"}}>Resumo operacional e pipeline</p>
      </header>

      <div className="kpi-grid section">
        <div className="card"><div className="card-body kpi"><span className="label">Projetos ativos</span><span className="value">14</span></div></div>
        <div className="card"><div className="card-body kpi"><span className="label">Leads no pipeline</span><span className="value">52</span></div></div>
        <div className="card"><div className="card-body kpi"><span className="label">Conversão</span><span className="value">18%</span></div></div>
        <div className="card"><div className="card-body kpi"><span className="label">Receita (Mês)</span><span className="value">R$ 214k</span></div></div>
      </div>

      <div className="section card">
        <div className="card-body">
          <div className="card-title">Pipeline recente</div>
          <div style={{overflowX:"auto"}}>
            <table className="table">
              <thead><tr><th>Empresa</th><th>Fase</th><th>Owner</th><th>Valor</th></tr></thead>
              <tbody>
                <tr><td>Heineken</td><td>Proposta</td><td>Ana</td><td>R$ 80k</td></tr>
                <tr><td>ACME</td><td>Descoberta</td><td>João</td><td>R$ 25k</td></tr>
                <tr><td>Natura</td><td>Negociação</td><td>Maria</td><td>R$ 60k</td></tr>
                <tr><td>Itaú</td><td>Fechado</td><td>Carlos</td><td>R$ 49k</td></tr>
              </tbody>
              <tfoot><tr><td colSpan={4}>Dados ilustrativos</td></tr></tfoot>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
