"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Topbar() {
  const pathname = usePathname();
  return (
    <header className="w-full sticky top-0 z-40 border-b" style={{borderColor:"var(--border)", backdropFilter: "saturate(180%) blur(4px)"}}>
      <div className="max-w-screen-2xl mx-auto px-4 h-14 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="size-7 rounded-md" style={{background:"var(--brand-accent)"}} />
          <span className="font-display font-semibold tracking-wide">Engage Dashboard</span>
        </div>
        <nav className="flex items-center gap-3 text-sm">
          <code className="px-2 py-1 rounded border hidden md:block" style={{borderColor:"var(--border)"}}>{pathname}</code>
          <form action="/api/logout" method="post">
            <button className="btn btn-outline">Sair</button>
          </form>
          <Link href="/login" className="btn btn-primary">Login</Link>
        </nav>
      </div>
    </header>
  );
}
