import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;
  // Libera estáticos e páginas públicas
  if (
    pathname.startsWith("/_next") ||
    pathname.startsWith("/public") ||
    pathname === "/login" ||
    pathname.startsWith("/api/auth") ||
    pathname.startsWith("/api/logout")
  ) {
    return NextResponse.next();
  }

  const role = req.cookies.get("role")?.value;

  // Rotas sponsor exigem role sponsor
  if (pathname.startsWith("/sponsor")) {
    if (role !== "sponsor") {
      const url = req.nextUrl.clone();
      url.pathname = "/login";
      return NextResponse.redirect(url);
    }
    return NextResponse.next();
  }

  // Outras rotas (dashboard interno) exigem admin
  if (!role || role !== "admin") {
    const url = req.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!_next|public).*)"],
};
