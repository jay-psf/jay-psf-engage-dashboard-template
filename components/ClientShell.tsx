"use client";
import { useEffect } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import Sidebar from "@/components/ui/Sidebar";
import type { Role } from "@/components/lib/types";

type Props = {
  children: React.ReactNode;
  role: Role | undefined;
  brand?: string;
};

export default function ClientShell({ children, role, brand }: Props) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";

  // Aplica tema: sponsor = dark, admin = light
  useEffect(() => {
    const html = document.documentElement;
    if (role === "sponsor") html.setAttribute("data-theme", "dark");
    else html.removeAttribute("data-theme");
  }, [role]);

  if (isLogin) {
    // Tela de login sem chrome
    return <main className="min-h-screen grid place-items-center px-4">{children}</main>;
  }

  // App shell completo
  return (
    <>
      <Topbar role={role} brand={brand} />
      <div className="mx-auto grid max-w-screen-2xl grid-cols-[260px,1fr] gap-6 p-6">
        <Sidebar role={role} />
        <main className="min-h-[70vh] animate-[fadeIn_.3s_ease]">{children}</main>
      </div>
      <style>{`@keyframes fadeIn{from{opacity:.01;transform:translateY(6px)}to{opacity:1;transform:none}}`}</style>
    </>
  );
}
