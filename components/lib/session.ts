"use client";

export type Role = "admin" | "sponsor";
export type Session = { role?: Role; brand?: string; username?: string };

function getCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  const pairs = document.cookie.split("; ").map(s => s.split("="));
  const hit = pairs.find(([k]) => k === name);
  return hit ? decodeURIComponent(hit[1] ?? "") : undefined;
}

export function readSession(): Session {
  try {
    // Cookies (fonte oficial após /api/auth)
    const role = getCookie("role") as Role | undefined;
    const brand = getCookie("brand") || undefined;
    if (role) return { role, brand };

    // Fallback dev: localStorage
    const raw = typeof window !== "undefined" ? window.localStorage.getItem("session") : null;
    return raw ? (JSON.parse(raw) as Session) : {};
  } catch {
    return {};
  }
}
