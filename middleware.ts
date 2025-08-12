import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";

const PUBLIC_PATHS = ["/login", "/api/auth", "/api/logout", "/_next", "/favicon.ico"];

export function middleware(req: NextRequest) {
  const url = req.nextUrl;
  const isPublic = PUBLIC_PATHS.some((p) => url.pathname === p || url.pathname.startsWith(p + "/"));
  if (isPublic) return NextResponse.next();

  const role = req.cookies.get("role")?.value;
  if (!role) {
    const login = new URL("/login", url);
    return NextResponse.redirect(login);
  }

  // Regras simples de RBAC por rota:
  if (role === "sponsor" && !url.pathname.startsWith("/sponsor")) {
    return NextResponse.redirect(new URL(`/sponsor/${req.cookies.get("brand")?.value ?? "acme"}/overview`, url));
  }

  return NextResponse.next();
}
export const config = { matcher: ["/((?!_next|.*\\..*).*)"] };
