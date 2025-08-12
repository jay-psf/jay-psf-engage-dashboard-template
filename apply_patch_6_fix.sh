set -euo pipefail

echo "== Regravando components/lib/session.ts =="
mkdir -p components/lib
cat > components/lib/session.ts <<'TS'
"use client";

export type Role = "admin" | "sponsor";
export type Session = { role?: Role; brand?: string; username?: string };

export function readCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  const escaped = name.replace(/([.$?*|{}()[\]\\/+^])/g, "\\$1");
  const re = new RegExp("(?:^|; )" + escaped + "=([^;]*)");
  const m = document.cookie.match(re);
  return m ? decodeURIComponent(m[1]) : undefined;
}

export function readSession(): Session {
  if (typeof document === "undefined") return {};
  const role = readCookie("role") as Role | undefined;
  const brand = readCookie("brand");
  const username = readCookie("username");
  return { role, brand, username };
}
TS

echo "== Build =="
pnpm build || true
