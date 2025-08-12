"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

const NavItem = ({ href, label }: { href: string; label: string }) => {
  const pathname = usePathname();
  const active = pathname === href;
  return (
    <Link
      href={href}
      className={`flex items-center gap-2 px-3 py-2 rounded-xl border transition
        ${active ? "bg-black/5 dark:bg-white/10" : "hover:bg-black/5"}`
      }
      style={{borderColor:"var(--border)"}}
    >
      <div className="size-2 rounded-full" style={{background:"var(--brand-accent)"}} />
      <span>{label}</span>
    </Link>
  );
};

export default function Sidebar() {
  return (
    <aside className="w-64 shrink-0 p-4 hidden md:block">
      <div className="card p-4">
        <div className="text-sm" style={{color:"var(--muted)"}}>Navegação</div>
        <div className="grid gap-2 mt-2">
          <NavItem href="/" label="Dashboard" />
          <NavItem href="/pipeline" label="Pipeline" />
          <NavItem href="/projetos" label="Projetos" />
          <NavItem href="/admin" label="Admin" />
        </div>
        <div className="hr my-4" />
        <div className="text-sm" style={{color:"var(--muted)"}}>Acesso Patrocinador</div>
        <div className="mt-2 grid gap-2">
          <NavItem href="/sponsor/acme/overview" label="Overview" />
          <NavItem href="/sponsor/acme/results" label="Resultados" />
        </div>
      </div>
    </aside>
  );
}
