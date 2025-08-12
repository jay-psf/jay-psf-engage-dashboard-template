import "../styles/globals.css";
import "../styles/tokens.css";
import type { Metadata } from "next";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR">
      <body>
        <Topbar />
        <div className="max-w-7xl mx-auto px-4 py-6 flex gap-6">
          <Sidebar />
          <main className="flex-1 space-y-6">{children}</main>
        </div>
      </body>
    </html>
  );
}
