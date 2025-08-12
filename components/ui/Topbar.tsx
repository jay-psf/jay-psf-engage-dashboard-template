"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Topbar() {
  const pathname = usePathname();
  return (
    <header className="w-full border-b bg-white/70 backdrop-blur supports-[backdrop-filter]:bg-white/60">
      <div className="max-w-screen-2xl mx-auto px-4 h-14 flex items-center justify-between">
        <div className="font-semibold">Engage Dashboard</div>
        <nav className="flex items-center gap-3 text-sm">
          <span className="text-neutral-500 hidden sm:inline">Rota:</span>
          <code className="px-2 py-1 bg-neutral-100 rounded">{pathname}</code>
          <Link href="/login" className="px-3 py-1 border rounded hover:bg-neutral-50">
            Login
          </Link>
        </nav>
      </div>
    </header>
  );
}
