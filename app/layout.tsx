import "./styles/globals.css";
import "./styles/tokens.css";
import type { Metadata } from "next";
import { cookies } from "next/headers";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const roleCookie = cookies().get("role")?.value as "admin" | "sponsor" | undefined;
  const brand = cookies().get("brand")?.value || "heineken";
  const role: "admin" | "sponsor" = roleCookie === "sponsor" ? "sponsor" : "admin";
  const isSponsor = role === "sponsor";
  const htmlTheme = isSponsor ? "dark" : "light";
  const brandLogo = isSponsor ? ("/logos/heineken.png" /* ou .jpg/.svg, ajuste se precisar */) : undefined;

  return (
    <html lang="pt-BR" data-theme={htmlTheme}>
      <body className="min-h-screen bg-[var(--bg)] text-[var(--text)]">
        <Topbar role={role} brandLogo={brandLogo} />
        <div className="mx-auto grid max-w-screen-2xl grid-cols-[260px,1fr] gap-6 p-6">
          <Sidebar role={role} brand={brand} />
          <main className="min-h-[70vh]">{children}</main>
        </div>
      </body>
    </html>
  );
}
