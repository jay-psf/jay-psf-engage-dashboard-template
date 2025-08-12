"use client";
import { useEffect } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import { getThemePref, setThemeAttr, readSession } from "@/components/lib/session";

export default function ClientShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";
  const { role } = readSession();

  useEffect(() => {
    const pref = getThemePref();
    setThemeAttr(pref, role);
  }, [role]);

  if (isLogin) return <>{children}</>;
  return (
    <>
      <Topbar />
      <div className="mx-auto max-w-screen-2xl p-6">
        {children}
      </div>
    </>
  );
}
