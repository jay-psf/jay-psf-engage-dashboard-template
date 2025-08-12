set -euo pipefail

echo "== Patch 33 Hotfix: helpers de tema exportados =="

mkdir -p components/lib
cat > components/lib/session.ts <<'TS'
"use client";

export type Role = "admin" | "sponsor";
export type ThemePref = "light" | "dark" | "system";
export type Session = { role?: Role; brand?: string; username?: string };

export function readCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  const escaped = name.replace(/([.$?*|{}()[\]\\/+^])/g,"\\$1");
  const re = new RegExp("(?:^|; )"+escaped+"=([^;]*)");
  const m = document.cookie.match(re);
  return m ? decodeURIComponent(m[1]) : undefined;
}

export function readSession(): Session {
  if (typeof document === "undefined") return {};
  return {
    role: (readCookie("role") as Role | undefined),
    brand: readCookie("brand") || undefined,
    username: readCookie("username") || undefined,
  };
}

export function resolveBrandLogo(brand?: string){
  const b = (brand || "acme").toLowerCase();
  return `/logos/${b}.png`;
}

/* ======= Helpers de tema (faltavam as exports) ======= */
export function getThemePref(): ThemePref | null {
  if (typeof window === "undefined") return null;
  const v = window.localStorage.getItem("themePref");
  return (v === "light" || v === "dark" || v === "system") ? v : null;
}

export function saveThemePref(pref: ThemePref){
  if (typeof window === "undefined") return;
  window.localStorage.setItem("themePref", pref);
}

/** Aplica atributo data-theme no <html> conforme pref e papel (default sponsor=dark, admin=light) */
export function setThemeAttr(pref: ThemePref | null, role?: Role){
  if (typeof window === "undefined") return;
  const html = document.documentElement;
  let desired: ThemePref | "light" | "dark" | null = pref ?? (role === "sponsor" ? "dark" : "light");

  if (desired === "system"){
    const mq = window.matchMedia("(prefers-color-scheme: dark)");
    desired = mq.matches ? "dark" : "light";
  }

  if (desired === "dark") html.setAttribute("data-theme","dark");
  else html.removeAttribute("data-theme");
}

/** Conveniência: aplica o tema a partir do localStorage (fallback por papel) */
export function applyThemeFromStorage(role?: Role){
  const pref = getThemePref();
  setThemeAttr(pref, role);
}
TS

echo "== Build =="
pnpm build
