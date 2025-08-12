import "../styles/globals.css";
import "../styles/tokens.css";
import type { Metadata } from "next";
import { cookies } from "next/headers";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const cookieStore = cookies();
  const role = (cookieStore.get("role")?.value as "admin" | "sponsor") || "admin";
  const brand = cookieStore.get("brand")?.value || "";

  const themeClass = role === "sponsor" ? "theme-sponsor" : "theme-admin";

  return (
    <html lang="pt-BR">
      <body
        className={`${themeClass}`}
        data-role={role}
        data-brand={brand}
      >
        <div className="min-h-screen flex">
          <Sidebar />
          <div className="flex-1 flex flex-col">
            <Topbar />
            <main className="p-6">{children}</main>
          </div>
        </div>
      </body>
    </html>
  );
}
