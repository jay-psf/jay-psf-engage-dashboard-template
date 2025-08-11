import '../styles/globals.css';
import '../styles/tokens.css';
import type { Metadata } from 'next';
import { Sidebar } from '@/components/ui/Sidebar';
import { Topbar } from '@/components/ui/Topbar';

export const metadata: Metadata = {
  title: 'Engage Dashboard',
  description: 'Patrocínios & Ativações',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR" className="h-full">
      <body className="min-h-screen">
        <Topbar />
        <div className="mx-auto max-w-7xl grid grid-cols-1 md:grid-cols-[240px,1fr] lg:grid-cols-[280px,1fr]">
          <Sidebar />
          <main className="p-4 md:p-6 space-y-6">{children}</main>
        </div>
      </body>
    </html>
  );
}
