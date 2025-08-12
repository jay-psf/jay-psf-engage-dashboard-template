import "../styles/globals.css";
import "../styles/tokens.css";
import type { Metadata } from "next";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";
import { cookies } from "next/headers";

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const role = cookies().get("role")?.value;
  const themeClass = role === "sponsor" ? "theme-sponsor" : "theme-admin";

  return (
    <html lang="pt-BR" className={themeClass}>
      <body>
        <Topbar />
        <div className="min-h-screen max-w-screen-2xl mx-auto px-4 py-6 flex gap-6">
          <Sidebar />
          <main className="flex-1 grid gap-6">{children}</main>
        </div>
      </body>
    </html>
  );
}
