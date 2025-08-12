"use client";

export type Role = "admin" | "sponsor";
export type Session = { role?: Role; brand?: string; username?: string };

export function readCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  const escaped = name.replace(/([.$?*|{}()[\]\\/+^])/g, "\\$1");
  const re = new RegExp("(?:^|; )" + escaped + "=([^;]*)");
  const m = document.cookie.match(re);
  return m ? decodeURIComponent(m[1]) : undefined;
}

export function readSession(): Session {
  return {
    role: (readCookie("role") as Role | undefined),
    brand: readCookie("brand") || undefined,
    username: readCookie("username") || undefined,
  };
}
