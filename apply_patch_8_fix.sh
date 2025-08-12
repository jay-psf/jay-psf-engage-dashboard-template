set -euo pipefail
echo "== Corrigindo <img> na Topbar (style -> className) =="

cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import { readCookie } from "@/components/lib/session";

export default function Topbar() {
  const role = typeof document !== "undefined" ? readCookie("role") : undefined;
  const brand = typeof document !== "undefined" ? readCookie("brand") : undefined;

  async function logout() {
    await fetch("/api/logout", { method: "POST" });
    window.location.href = "/login";
  }

  return (
    <header className="sticky top-0 z-30 bg-[var(--bg)]/90 backdrop-blur-lg border-b border-border">
      <div className="mx-auto max-w-screen-2xl flex items-center justify-between gap-4 px-6 py-3">
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 grid place-items-center rounded-xl bg-[var(--surface)] border border-border font-semibold">E</div>
          <span className="font-semibold">Engage</span>
        </div>

        <div className="flex items-center gap-3">
          {role === "sponsor" && (
            <div className="flex items-center gap-2 rounded-full border border-border bg-[var(--surface)] px-3 py-1.5">
              <img
                src="/logos/heineken.png"
                alt={brand ?? "brand"}
                width={20}
                height={20}
                className="block rounded-md"
              />
              <span className="text-sm font-medium capitalize">{brand}</span>
            </div>
          )}

          <button onClick={logout} className="btn btn-outline">Sair</button>
        </div>
      </div>
    </header>
  );
}
TSX

echo "== Build =="
pnpm build
