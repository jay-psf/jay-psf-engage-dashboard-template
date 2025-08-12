"use client";
import Link from "next/link";
import { useRouter } from "next/navigation";
import BrandPill from "./BrandPill";
import { readCookie } from "@/components/lib/session";

export default function Topbar() {
  const router = useRouter();

  const role = readCookie("role") as "admin" | "sponsor" | undefined;
  const brand = readCookie("brand") ?? undefined;

  async function logout() {
    await fetch("/api/logout", { method: "POST" });
    // volta ao login
    window.location.href = "/login";
  }

  return (
    <header className="topbar">
      <div className="mx-auto flex max-w-screen-2xl items-center justify-between gap-3 px-4 py-3">
        <div className="flex items-center gap-3">
          <Link href="/" className="font-semibold tracking-tight">
            Engage
          </Link>
          {role === "sponsor" && brand ? (
            <span className="text-muted hidden sm:inline">/ {brand}</span>
          ) : null}
        </div>

        <div className="flex items-center gap-3">
          <BrandPill
            brand={role === "sponsor" ? brand : undefined}
            username={role === "admin" ? "admin" : brand}
            onClick={() => router.push("/settings")}
          />
          <button className="btn btn-outline h-10 px-4" onClick={logout}>Sair</button>
        </div>
      </div>
    </header>
  );
}
