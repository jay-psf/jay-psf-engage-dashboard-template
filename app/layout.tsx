import "../styles/globals.css";
import "../styles/tokens.css";
import type { Metadata } from "next";

export const metadata: Metadata = { title: "Engage Dashboard" };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR">
      <body className="min-h-screen bg-[var(--bg)] text-[var(--text)]">
        {children}
      </body>
    </html>
  );
}
