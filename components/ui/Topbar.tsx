"use client";
import Link from "next/link";

export default function Topbar() {
  return (
    <header className="h-12 border-b bg-white flex items-center justify-between px-3">
      <div className="text-sm text-neutral-600">
        Entourage Engage · Unidade Engage
      </div>
      <nav className="flex items-center gap-3">
        <Link href="/login" className="text-sm underline">Perfil de acesso</Link>
        <form method="POST" action="/api/logout">
          <button className="text-sm px-3 py-1 border rounded">Sair</button>
        </form>
      </nav>
    </header>
  );
}
