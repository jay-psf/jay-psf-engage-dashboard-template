import "../styles/globals.css";
import "../styles/tokens.css";
import { cookies } from "next/headers";
import ClientShell from "@/components/ClientShell";
import type { Role } from "@/components/lib/types";

export const metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {

  return (
    <html lang="pt-BR">
      <body className="min-h-screen bg-[var(--bg)] text-[var(--text)]">
        <ClientShell>{children}</ClientShell>
      </body>
    </html>
  );
}
