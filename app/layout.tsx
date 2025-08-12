import "../styles/globals.css";
import "../styles/tokens.css";
import type { Metadata } from "next";
import { cookies } from "next/headers";
import { Inter } from "next/font/google";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const c = cookies();
  const role = c.get("role")?.value || "guest"; // admin | sponsor | guest
  const themeClass = role === "sponsor" ? "dark" : ""; // admin=claro, sponsor=escuro

  return (
    <html lang="pt-BR" className={`${themeClass} ${inter.variable}`}>
      <body className="font-sans bg-entourage-bg-light text-entourage-text-light dark:bg-entourage-bg-dark dark:text-entourage-text-dark">
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
