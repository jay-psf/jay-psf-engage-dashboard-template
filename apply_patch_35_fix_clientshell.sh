set -euo pipefail
echo "== Patch 35: Reescreve ClientShell (remove lixo e corrige render) =="

cat > components/ClientShell.tsx <<'TSX'
"use client";

import { ReactNode, useEffect } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import { readSession, setThemeAttr } from "@/components/lib/session";

export default function ClientShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const { role } = readSession();

  // Aplica o tema conforme preferência/sessão
  useEffect(() => {
    setThemeAttr(undefined, role);
  }, [role]);

  // Sem chrome nas telas de autenticação
  const isAuth = pathname === "/login" || pathname === "/forgot-password";
  if (isAuth) {
    return (
      <main className="min-h-screen flex items-center justify-center px-4 py-10">
        <div className="w-full max-w-md">{children}</div>
      </main>
    );
  }

  return (
    <>
      <Topbar />
      <div className="mx-auto max-w-screen-2xl px-6 py-8">
        {children}
      </div>
    </>
  );
}
TSX

echo "== Build =="
pnpm build
