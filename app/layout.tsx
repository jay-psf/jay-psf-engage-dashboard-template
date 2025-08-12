import "../styles/globals.css";
import type { Metadata } from "next";
import { cookies } from "next/headers";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }){
  const c = cookies();
  const role = (c.get("role")?.value === "sponsor" ? "sponsor" : "admin") as "admin"|"sponsor";
  const brand = c.get("brand")?.value;
  const theme = role === "sponsor" ? "dark" : undefined;

  return (
    <html lang="pt-BR" data-theme={theme}>
      <body>
        <Topbar role={role} brand={brand} />
        <div className="mx-auto grid max-w-screen-2xl grid-cols-[260px,1fr] gap-6 p-6">
          <Sidebar role={role} />
          <main className="min-h-[70vh]">{children}</main>
        </div>
      </body>
    </html>
  );
}
