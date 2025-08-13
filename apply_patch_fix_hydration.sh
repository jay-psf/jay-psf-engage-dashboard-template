set -euo pipefail
echo "== Fix hydration: ClientShell sempre renderiza <main> =="

cat > components/ClientShell.tsx <<'TSX'
"use client";

import { ReactNode, useEffect } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import { readSession, setThemeAttr } from "@/components/lib/session";

export default function ClientShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const { role } = readSession();

  // Mantém tema coerente sem afetar marcação SSR
  useEffect(() => { setThemeAttr(null, role); }, [role]);

  const isAuth = pathname === "/login" || pathname === "/forgot-password";
  const wrapClass = isAuth
    ? "min-h-screen flex items-center justify-center p-6"
    : "mx-auto grid max-w-screen-2xl grid-cols-[1fr] gap-6 p-6 md:grid-cols-[260px,1fr]";

  return (
    <>
      {!isAuth && <Topbar />}
      <div className={wrapClass}>
        <main className={isAuth ? "w-full max-w-md" : "min-h-[70vh]"}>{children}</main>
      </div>
    </>
  );
}
TSX

echo "== Build limpo =="
rm -rf .next .turbo .vercel/output tsconfig.tsbuildinfo
pnpm build
