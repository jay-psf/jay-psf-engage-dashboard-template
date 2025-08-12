"use client";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import { readSession } from "@/components/lib/session";

export default function ClientShell({ children }:{children:React.ReactNode}){
  const pathname = usePathname();
  const isLogin = pathname === "/login";
  const { role } = readSession();

  if (typeof window !== "undefined") {
    const pref = localStorage.getItem("theme-pref");
    const html = document.documentElement;
    if (pref === "light" || pref === "dark") html.setAttribute("data-theme", pref);
    else {
      const sys = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark":"light";
      html.setAttribute("data-theme", role === "sponsor" ? "dark" : sys);
    }
  }

  if (isLogin) return <>{children}</>;
  return (
    <>
      <Topbar/>
      <div className="mx-auto max-w-screen-2xl px-4 py-6">
        <main className="min-h-[70vh]">{children}</main>
      </div>
    </>
  );
}
