"use client";
import { usePathname } from "next/navigation";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

export default function LayoutShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";

  if (isLogin) {
    // Tela de login full-screen, sem chrome
    return (
      <div className="min-h-screen">{children}</div>
    );
  }

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text)]">
      <Topbar />
      <div className="mx-auto grid max-w-screen-2xl grid-cols-[260px,1fr] gap-6 p-6">
        <Sidebar />
        <main className="min-h-[70vh]">{children}</main>
      </div>
    </div>
  );
}
