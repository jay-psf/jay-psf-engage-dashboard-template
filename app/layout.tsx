import "../styles/globals.css";
import "../styles/tokens.css";
import type { Metadata } from "next";
import { inter, sora } from "./fonts";
import LayoutShell from "@/components/LayoutShell";

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR" className={`${inter.variable} ${sora.variable}`}>
      <body className="body-font">
        <LayoutShell>{children}</LayoutShell>
      </body>
    </html>
  );
}
