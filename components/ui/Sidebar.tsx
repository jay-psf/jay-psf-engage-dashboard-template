'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

const items = [
  { href: '/', label: 'Dashboard' },
  { href: '/pipeline', label: 'Pipeline' },
  { href: '/projetos', label: 'Projetos' },
  { href: '/admin', label: 'Admin' },
];

export function Sidebar(){
  const pathname = usePathname();
  return (
    <aside className="hidden md:flex md:w-60 lg:w-72 flex-col gap-2 p-4 border-r border-neutral-200 dark:border-neutral-800">
      <div className="px-3 py-3 text-sm font-semibold">Entourage Engage</div>
      <nav className="flex flex-col gap-1">
        {items.map(it => {
          const active = pathname === it.href;
          return (
            <Link key={it.href} href={it.href} className={`sidebar-link ${active ? 'bg-neutral-100 dark:bg-neutral-800' : ''}`}>
              <span>{it.label}</span>
            </Link>
          )
        })}
      </nav>
      <div className="mt-auto px-3 text-xs text-neutral-500">America/Sao_Paulo · BRL</div>
    </aside>
  );
}
