"use client";
import Image from "next/image";
import Button from "./Button";

export default function Topbar({ role, brandLogo }: { role: "admin"|"sponsor"; brandLogo?: string }) {
  return (
    <header className="sticky top-0 z-40 h-16 bg-[var(--bg)]/80 backdrop-blur border-b border-border flex items-center">
      <div className="mx-auto flex w-full max-w-screen-2xl items-center justify-between px-6">
        <div className="flex items-center gap-3">
          {brandLogo ? (
            <div className="h-8 w-28 relative">
              <Image src={brandLogo} alt="Logo patrocinador" fill className="object-contain" sizes="112px" />
            </div>
          ) : (
            <div className="text-lg font-semibold tracking-tight">Entourage • Engage</div>
          )}
        </div>
        <nav className="flex items-center gap-2">
          <form action="/api/logout" method="post">
            <Button type="submit" variant="outline">Sair</Button>
          </form>
        </nav>
      </div>
    </header>
  );
}
