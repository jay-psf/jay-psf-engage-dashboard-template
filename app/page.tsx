export default function Page() {
  return (
    <div className="space-y-6">
      <header className="space-y-2">
        <h1 className="text-2xl font-semibold">Engage – Template Codespaces</h1>
        <p className="text-sm text-neutral-600 dark:text-neutral-400">
          Se você está vendo esta página no Codespaces, o ambiente está pronto.
        </p>
      </header>

      <section className="rounded-xl border border-neutral-200 dark:border-neutral-800 p-6">
        <ol className="list-decimal ml-6 space-y-2">
          <li>Abra o terminal e rode <code className="px-1 py-0.5 rounded bg-neutral-100 dark:bg-neutral-900">pnpm dev</code></li>
          <li>Acesse a URL de preview para ver a aplicação rodando</li>
          <li>Faça commit e conecte na Vercel para deploy automático</li>
        </ol>
      </section>
    </div>
  );
}
