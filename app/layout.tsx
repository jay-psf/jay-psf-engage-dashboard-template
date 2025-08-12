import "./styles/globals.css";
import "./styles/tokens.css";
import { cookies } from "next/headers";
import ClientShell from "@/components/ClientShell";
import type { Role } from "@/components/lib/types";

export const metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const role = (cookies().get("role")?.value as Role | undefined) ?? undefined;
  const brand = cookies().get("brand")?.value;

  return (
    <html lang="pt-BR">
      <body className="min-h-screen bg-[var(--bg)] text-[var(--text)]">
        <ClientShell role={role} brand={brand}>{children}</ClientShell>
      </body>
    </html>
  );
}
