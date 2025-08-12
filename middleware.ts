import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // Sempre permitir login/auth/logout e estáticos
  if (
    pathname.startsWith("/login") ||
    pathname.startsWith("/api/auth") ||
    pathname.startsWith("/api/logout") ||
    pathname.startsWith("/_next") ||
    pathname.startsWith("/static") ||
    pathname === "/denied"
  ) {
    return NextResponse.next();
  }

  const role = req.cookies.get("engage_role")?.value;

  // Rotas patrocinador
  if (pathname.startsWith("/sponsor/")) {
    if (role !== "sponsor") {
      return NextResponse.redirect(new URL("/denied", req.url));
    }
    return NextResponse.next();
  }

  // Rotas internas (exigem admin)
  const internalPrefixes = ["/", "/pipeline", "/projetos", "/admin"];
  const isInternal = internalPrefixes.some((p) =>
    pathname === p || pathname.startsWith(p + "/")
  );
  if (isInternal) {
    if (role !== "admin") {
      return NextResponse.redirect(new URL("/denied", req.url));
    }
    return NextResponse.next();
  }

  // fallback
  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!favicon.ico).*)"],
};
