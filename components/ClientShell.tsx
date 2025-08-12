"use client";
import { useEffect, useMemo } from "react";
import { usePathname } from "next/navigation";

function readCookie(name:string){
  const m = `; ${document.cookie}`.match(`;\\s*${name}=([^;]+)`);
  return m ? decodeURIComponent(m[1]) : "";
}

export default function ClientShell({ children }:{children:React.ReactNode}){
  const pathname = usePathname();
  const role = useMemo(()=> readCookie("role") || "admin", []);
  const brand = useMemo(()=> readCookie("brand") || "acme", []);
  const isLogin = pathname === "/login";

  useEffect(()=>{
    if(role === "sponsor") document.documentElement.setAttribute("data-theme","dark");
    else document.documentElement.removeAttribute("data-theme");
  },[role]);

  return (
    <>
      {/* mini style para transições suaves */}
      <style>{`*{scrollbar-gutter:stable} main{animation:fadeIn .18s ease} @keyframes fadeIn{from{opacity:.01;transform:translateY(4px)} to{opacity:1;transform:none}}`}</style>
      <div data-role={role} data-brand={brand}>
        {children}
      </div>
      {isLogin ? null : null}
    </>
  );
}
