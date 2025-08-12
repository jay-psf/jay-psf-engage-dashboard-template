import Link from "next/link";
import { cookies } from "next/headers";

const NavItem = ({ href, children }: { href: string; children: React.ReactNode }) => (
  <Link
    href={href}
    className="block rounded-xl2 border border-entourage-line-light bg-entourage-surface-light px-4 py-3 shadow-soft hover:shadow transition
               dark:border-entourage-line-dark dark:bg-entourage-surface-dark"
  >
    {children}
  </Link>
);

export default function Sidebar() {
  const c = cookies();
  const role = c.get("role")?.value || "guest";
  const brand = c.get("brand")?.value || "acme";

  return (
    <aside className="w-[280px] hidden md:block border-r border-entourage-line-light/70 dark:border-entourage-line-dark/70">
      <div className="p-4 space-y-6">
        <div>
          <div className="text-sm opacity-70 mb-2">Navegação</div>
          <div className="space-y-3">
            {role !== "sponsor" && (
              <>
                <NavItem href="/">Dashboard</NavItem>
                <NavItem href="/pipeline">Pipeline</NavItem>
                <NavItem href="/projetos">Projetos</NavItem>
                <NavItem href="/admin">Admin</NavItem>
              </>
            )}
          </div>
        </div>

        <div>
          <div className="text-sm opacity-70 mb-2">Patrocinador</div>
          <div className="space-y-3">
            <NavItem href={`/sponsor/${brand}/overview`}>Overview</NavItem>
            <NavItem href={`/sponsor/${brand}/results`}>Resultados</NavItem>
            <NavItem href={`/sponsor/${brand}/financials`}>Financeiro</NavItem>
          </div>
        </div>
      </div>
    </aside>
  );
}
