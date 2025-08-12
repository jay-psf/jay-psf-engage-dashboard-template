"use client";

export type Role = "admin" | "sponsor";
export type ThemePref = "light" | "dark" | "system";
export type Session = { role?: Role; brand?: string; username?: string };

export function readCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  // Escapa com segurança o nome do cookie
  const escaped = name.replace(/([.$?*|{}()[\]\\/+^])/g, "\\$1");
  const re = new RegExp("(?:^|; )" + escaped + "=([^;]*)");
  const m = document.cookie.match(re);
  return m ? decodeURIComponent(m[1]) : undefined;
}

export function readSession(): Session {
  if (typeof document === "undefined") return {};
  const role = readCookie("role") as Role | undefined;
  const brand = readCookie("brand");
  const username = readCookie("username") || undefined;
  return { role, brand, username };
}

export function setThemeAttr(theme: ThemePref, role?: Role) {
  const el = document.documentElement;
  let mode: "light"|"dark";
  if (theme === "system") {
    const mq = window.matchMedia("(prefers-color-scheme: dark)");
    mode = mq.matches ? "dark" : "light";
  } else {
    mode = theme;
  }
  // regra: sponsor preferencialmente dark, mas respeita settings se for explicitamente "light"
  if (role === "sponsor" && theme !== "light") mode = "dark";
  el.setAttribute("data-theme", mode);
}

export function getThemePref(): ThemePref {
  if (typeof window === "undefined") return "system";
  return (localStorage.getItem("themePref") as ThemePref) || "system";
}

export function saveThemePref(pref: ThemePref) {
  if (typeof window === "undefined") return;
  localStorage.setItem("themePref", pref);
}

export function clearSessionAndGoLogin() {
  try {
    if (typeof document !== "undefined") {
      // limpa cookies simples (role/brand/username)
      document.cookie = "role=; Max-Age=0; path=/";
      document.cookie = "brand=; Max-Age=0; path=/";
      document.cookie = "username=; Max-Age=0; path=/";
    }
    if (typeof window !== "undefined") {
      localStorage.clear();
      sessionStorage.clear();
    }
  } finally {
    if (typeof window !== "undefined") window.location.href = "/login";
  }
}
