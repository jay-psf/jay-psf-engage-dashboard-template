"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Topbar() {
  const pathname = usePathname();
  return (
    <header className="w-full sticky top-0 z-40">
      <div className="backdrop-blur supports-[backdrop-filter]:bg-white/5 border-b border-white/10">
        <div className="max-w-screen-2xl mx-auto px-4 h-14 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="size-7 rounded-md bg-[var(--brand-accent)]" />
            <span className="font-semibold tracking-wide">Engage Dashboard</span>
          </div>
          <nav className="flex items-center gap-3 text-sm">
            <span className="hidden sm:inline text-muted">Rota:</span>
            <code className="px-2 py-1 rounded bg-white/5 border border-white/10">{pathname}</code>
            <Link href="/login" className="btn-primary">Login</Link>
          </nav>
        </div>
      </div>
    </header>
  );
}
