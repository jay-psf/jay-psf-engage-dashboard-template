set -euo pipefail
echo "== Fix hydration v2: estrutura estável (Topbar + main SEMPRE) =="

cat > components/ClientShell.tsx <<'TSX'
"use client";

import { ReactNode, useEffect, useMemo } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import { setThemeAttr, readSession } from "@/components/lib/session";

/**
 * Regra de ouro p/ evitar hydration:
 *  - NÃO condicionar a presença de elementos (Topbar/main) ao pathname.
 *  - Mantenha a mesma árvore no SSR e CSR; use classes para ocultar.
 */
export default function ClientShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  // Não usa readSession() para decidir estrutura; apenas para tema (side-effect)
  const { role } = readSession();

  // Tema não influencia estrutura; só atributo em <html>
  useEffect(() => { setThemeAttr(null, role); }, [role]);

  // Detecta telas de autenticação, mas só para classe CSS (não remove nós)
  const isAuth = useMemo(
    () => pathname === "/login" || pathname === "/forgot-password",
    [pathname]
  );

  return (
    <>
      {/* Topbar SEMPRE presente; oculto visualmente em telas de auth */}
      <div className={isAuth ? "sr-only" : ""} aria-hidden={isAuth ? "true" : "false"}>
        <Topbar />
      </div>

      {/* Wrapper e main SEMPRE presentes */}
      <div className={isAuth
        ? "min-h-screen flex items-center justify-center p-6"
        : "mx-auto max-w-screen-2xl p-6"
      }>
        <main className={isAuth ? "w-full max-w-md" : "min-h-[70vh]"}>
          {children}
        </main>
      </div>
    </>
  );
}
TSX

echo "== Limpa cache e recompila =="
rm -rf .next .turbo .vercel/output tsconfig.tsbuildinfo
pnpm build
