import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // Sempre permitir login/auth/logout e assets estáticos
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

  // Rotas de patrocinador exigem role sponsor
  if (pathname.startsWith("/sponsor/")) {
    if (role !== "sponsor") {
      return NextResponse.redirect(new URL("/denied", req.url));
    }
  }

  // Rotas internas: por enquanto liberadas para qualquer (você pode endurecer depois)
  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!api/seed|favicon.ico).*)"],
};
