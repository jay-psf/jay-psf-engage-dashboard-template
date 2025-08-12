"use client";
import { usePathname } from "next/navigation";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

export default function LayoutShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";

  if (isLogin) {
    // No chrome na tela de login
    return (
      <main className="min-h-screen grid place-items-center px-4">
        <div className="w-full max-w-4xl">{children}</div>
      </main>
    );
  }

  return (
    <>
      <Topbar />
      <div className="mx-auto grid max-w-screen-2xl grid-cols-[260px,1fr] gap-6 p-6">
        <Sidebar />
        <main className="min-h-[70vh]">{children}</main>
      </div>
    </>
  );
}
