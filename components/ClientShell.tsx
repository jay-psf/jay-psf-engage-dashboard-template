"use client";
import { useEffect, useState } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import Sidebar from "@/components/ui/Sidebar";
import { readSession } from "@/components/lib/session";

export default function ClientShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    // tema inicial por papel
    const sess = readSession();
    const mode = sess.role === "sponsor" ? "dark" : "light";
    const current = document.documentElement.getAttribute("data-theme");
    if (!current) document.documentElement.setAttribute("data-theme", mode);
    setMounted(true);
  }, []);

  if (isLogin) {
    return <main className="min-h-[calc(100vh-0px)]">{children}</main>;
  }

  if (!mounted) return null;

  return (
    <>
      <Topbar />
      <div className="mx-auto grid max-w-screen-2xl grid-cols-[260px,1fr] gap-6 p-6">
        <Sidebar />
        <main className="min-h-[70vh] animate-[fadeIn_.3s_ease]">{children}</main>
      </div>
    </>
  );
}
