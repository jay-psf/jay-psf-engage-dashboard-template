import { NextRequest, NextResponse } from "next/server";

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;
  const role = req.cookies.get("role")?.value;
  const brand = req.cookies.get("brand")?.value;

  // Público
  if (pathname === "/login" || pathname.startsWith("/api")) {
    return NextResponse.next();
  }

  // Sem sessão => login
  if (!role) {
    const url = req.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  // Patrocinador: trava fora do escopo /sponsor/[brand]/*
  if (role === "sponsor") {
    const b = brand || "heineken";
    if (!pathname.startsWith(`/sponsor/${b}`)) {
      const url = req.nextUrl.clone();
      url.pathname = `/sponsor/${b}/overview`;
      return NextResponse.redirect(url);
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"],
};
