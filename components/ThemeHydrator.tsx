"use client";
import { useEffect } from "react";
import { usePathname } from "next/navigation";

type Sess = { role?: "admin"|"sponsor"; brand?: string };

function readSession(): Sess {
  try {
    const raw = localStorage.getItem("session");
    return raw ? JSON.parse(raw) as Sess : {};
  } catch { return {}; }
}

export default function ThemeHydrator() {
  const pathname = usePathname();

  useEffect(() => {
    const s = readSession();
    const html = document.documentElement;
    if (s.role === "sponsor") html.setAttribute("data-theme", "dark");
    else html.removeAttribute("data-theme");
  }, [pathname]);

  return null;
}
