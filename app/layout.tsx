import "../styles/globals.css";
import Link from "next/link";

export const metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações – Skeleton",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR">
      <body className="min-h-screen grid grid-cols-[240px_1fr] bg-neutral-50 text-neutral-900 dark:bg-neutral-950 dark:text-neutral-100">
        <aside className="h-screen sticky top-0 border-r border-neutral-200/60 dark:border-neutral-800/60 p-4">
          <div className="font-semibold text-sm mb-4">Entourage Engage</div>
          <nav className="flex flex-col gap-2 text-sm">
            <Link href="/" className="hover:underline">/dashboard</Link>
            <Link href="/pipeline" className="hover:underline">/pipeline</Link>
            <Link href="/projetos" className="hover:underline">/projetos</Link>
            <Link href="/admin" className="hover:underline">/admin</Link>
          </nav>
        </aside>
        <main className="p-6">
          <header className="mb-6 flex items-center justify-between">
            <h1 className="text-xl font-semibold">Dashboard</h1>
            <div className="text-xs opacity-70">pt-BR · America/Sao_Paulo · BRL</div>
          </header>
          {children}
        </main>
      </body>
    </html>
  );
}
