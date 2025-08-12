export const metadata = { title: "Settings • Engage" };
export default function SettingsPage() {
  return (
    <section className="rounded-2xl border border-border bg-card p-6 shadow-soft">
      <h1 className="text-xl font-semibold">Dados da Empresa</h1>
      <p className="mt-2 text-sm text-muted">Configure nome, CNPJ, e-mail e telefone.</p>
      <form className="mt-6 grid gap-4 md:grid-cols-2">
        <label className="block">
          <div className="text-sm mb-1">Nome</div>
          <input className="input rounded-xl" placeholder="Ex.: Heineken Brasil" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">CNPJ</div>
          <input className="input rounded-xl" placeholder="00.000.000/0000-00" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">E-mail</div>
          <input className="input rounded-xl" placeholder="contato@empresa.com" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">Telefone</div>
          <input className="input rounded-xl" placeholder="(11) 99999-9999" />
        </label>
        <div className="md:col-span-2">
          <button type="button" className="px-5 py-2.5 rounded-xl bg-accent text-white shadow-soft">Salvar</button>
        </div>
      </form>
    </section>
  );
}
