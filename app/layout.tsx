import "@/styles/globals.css";
import ClientShell from "@/components/ClientShell";

export const metadata = { title: "Engage" };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR">
      <body>
        <ClientShell>{children}</ClientShell>
      </body>
    </html>
  );
}
