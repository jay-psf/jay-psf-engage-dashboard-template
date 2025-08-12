"use client";
import { useEffect, useState } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import Sidebar from "@/components/ui/Sidebar";
import { readCookie } from "@/components/lib/session";

type ThemePref = "light" | "dark" | "system";

function resolveTheme(pref: ThemePref, fallbackByRole?: "light"|"dark") {
  if (pref === "system") {
    const m = window.matchMedia("(prefers-color-scheme: dark)");
    return m.matches ? "dark" : "light";
  }
  return pref || fallbackByRole || "light";
}

export default function ClientShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";

  // preferencia do usuário (localStorage)
  const [pref, setPref] = useState<ThemePref>("system");

  useEffect(() => {
    const stored = (localStorage.getItem("theme") as ThemePref) || "system";
    setPref(stored);

    const apply = () => {
      // papel ainda define fallback: sponsor = dark, admin = light (se system)
      const role = readCookie("role") as "sponsor"|"admin"|undefined;
      const fallback = role === "sponsor" ? "dark" : "light";
      const theme = resolveTheme(stored, fallback);
      const html = document.documentElement;
      if (theme === "dark") html.setAttribute("data-theme", "dark");
      else html.removeAttribute("data-theme");
    };

    apply();

    // atualiza se o sistema mudar quando pref=system
    const m = window.matchMedia("(prefers-color-scheme: dark)");
    const onChange = () => {
      const current = (localStorage.getItem("theme") as ThemePref) || "system";
      if (current === "system") apply();
    };
    m.addEventListener?.("change", onChange);
    return () => m.removeEventListener?.("change", onChange);
  }, []);

  if (isLogin) return <main className="min-h-[calc(100vh-64px)]">{children}</main>;

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
