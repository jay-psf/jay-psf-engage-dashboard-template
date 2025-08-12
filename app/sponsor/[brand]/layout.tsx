import Link from "next/link";

export default function SponsorLayout({
  children, params,
}: { children: React.ReactNode; params: { brand: string } }) {
  const brand = decodeURIComponent(params.brand || "");
  const base = `/sponsor/${encodeURIComponent(brand)}`;
  const tabs = [
    {href:`${base}/overview`, label:"Overview"},
    {href:`${base}/events`, label:"Eventos"},
    {href:`${base}/results`, label:"Resultados"},
    {href:`${base}/financials`, label:"Financeiro"},
    {href:`${base}/assets`, label:"Assets"},
  ];
  return (
    <div className="min-h-screen">
      <header className="border-b px-4 py-3 flex items-center justify-between bg-white">
        <div className="font-semibold">Patrocinador: {brand || "—"}</div>
        <form method="POST" action="/api/logout">
          <button className="text-sm border px-3 py-1 rounded">Sair</button>
        </form>
      </header>
      <nav className="px-4 border-b bg-neutral-50">
        <ul className="flex gap-4 text-sm">
          {tabs.map(t => (
            <li key={t.href}><Link className="inline-block py-3 hover:underline" href={t.href}>{t.label}</Link></li>
          ))}
        </ul>
      </nav>
      <main className="p-4">{children}</main>
    </div>
  );
}
