"use client";
import { usePathname } from "next/navigation";
import { useEffect, useMemo } from "react";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

type Session = { role?: "admin"|"sponsor"; brand?: string };
function readSession(): Session {
  try { const raw = localStorage.getItem("session"); return raw? JSON.parse(raw):{}; }
  catch { return {}; }
}

export default function ClientShell({children}:{children:React.ReactNode}){
  const path = usePathname();
  const isLogin = path.startsWith("/login");

  const role = useMemo(() => readSession().role ?? "admin", [isLogin]);
  useEffect(()=>{
    const s = readSession();
    if(s.role==="sponsor") document.documentElement.setAttribute("data-theme","dark");
    else document.documentElement.removeAttribute("data-theme");
  },[path]);

  if(isLogin) return <main className="min-h-screen grid place-items-center px-4">{children}</main>;

  return (
    <>
      <Topbar />
      <div className="mx-auto max-w-screen-2xl grid grid-cols-[260px,1fr] gap-6 p-6">
        <Sidebar />
        <main className="min-h-[70vh]">{children}</main>
      </div>
    </>
  );
}
