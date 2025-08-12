"use client";
import Image from "next/image";
import Link from "next/link";
import { useState } from "react";
import type { Role } from "@/components/lib/types";

export default function Topbar({ role, brand }: { role?: Role; brand?: string }) {
  const isSponsor = role === "sponsor";
  async function logout() {
    await fetch("/api/logout", { method: "POST" });
    window.location.href = "/login";
  }
  return (
    <header className="sticky top-0 z-40 border-b border-border bg-[var(--card)]/85 backdrop-blur">
      <div className="mx-auto flex max-w-screen-2xl items-center justify-between px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="h-8 w-8 rounded-xl bg-accent/15 grid place-items-center font-semibold text-sm text-[var(--text)]">E</div>
          <span className="font-semibold">Engage</span>
        </div>
        <div className="flex items-center gap-3">
          {isSponsor && (
            <div className="h-8 w-auto flex items-center gap-2 px-2 rounded-lg border border-border bg-[var(--surface)]">
              <Image
                src={`/logos/${brand ?? "acme"}.png`}
                alt={brand ?? "brand"}
                width={24}
                height={24}
              />
              <span className="text-sm">{brand ?? "Sponsor"}</span>
            </div>
          )}
          <Link href="/settings" className="h-9 w-9 overflow-hidden rounded-full border border-border bg-[var(--surface)]">
            <Image src="/avatar-placeholder.png" alt="Perfil" width={36} height={36} />
          </Link>
          <button onClick={logout} className="px-3 py-1.5 rounded-xl border border-border bg-accent text-white font-medium shadow-soft">
            Sair
          </button>
        </div>
      </div>
    </header>
  );
}
