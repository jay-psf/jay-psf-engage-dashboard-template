"use client";
import { useEffect } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import { readSession } from "@/components/lib/session";

export default function ClientShell({ children }: { children: React.ReactNode }){
  const pathname = usePathname();
  const { role } = readSession();

  useEffect(()=> {
    const pref = (typeof window !== "undefined") ? localStorage.getItem("themePref") : null;
    const html = document.documentElement;
    const desired = pref ?? (role === "sponsor" ? "dark" : "light");
    if (desired === "dark") html.setAttribute("data-theme","dark");
    else if (desired === "light") html.removeAttribute("data-theme");
    else {
      const mq = window.matchMedia("(prefers-color-scheme: dark)");
      if (mq.matches) html.setAttribute("data-theme","dark"); else html.removeAttribute("data-theme");
    }
  }, [role]);

  const isLogin = pathname === "/login";
  return (
    <>
      {!isLogin && <Topbar />}
      <main className={isLogin ? "" : "pt-[72px]"}>{children}</main>
    </>
  );
}
