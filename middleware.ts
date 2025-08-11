import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const PUBLIC_PATHS = [
  '/login',
  '/api/auth',
  '/api/logout',
  '/favicon.ico',
  '/robots.txt'
];

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;
  if (
    PUBLIC_PATHS.some((p) => pathname.startsWith(p)) ||
    pathname.startsWith('/_next') ||
    pathname.startsWith('/static') ||
    pathname.startsWith('/assets')
  ) {
    return NextResponse.next();
  }

  const role = req.cookies.get('role')?.value;
  const brand = req.cookies.get('brand')?.value;

  // Sponsor Portal: precisa ser 'sponsor' e só pode ver a própria brand
  if (pathname.startsWith('/sponsor/')) {
    const parts = pathname.split('/').filter(Boolean); // ['sponsor','brand',...]
    const brandSlug = parts[1] || '';
    if (role !== 'sponsor') {
      const url = new URL('/login', req.url);
      url.searchParams.set('next', pathname);
      return NextResponse.redirect(url);
    }
    if (brand && brand !== brandSlug) {
      return NextResponse.rewrite(new URL('/denied', req.url));
    }
    return NextResponse.next();
  }

  // Rotas internas: exigem papel interno
  const requiresInternal =
    pathname === '/' ||
    pathname.startsWith('/dashboard') ||
    pathname.startsWith('/pipeline') ||
    pathname.startsWith('/projetos') ||
    pathname.startsWith('/calendar') ||
    pathname.startsWith('/reports') ||
    pathname.startsWith('/admin');

  if (requiresInternal) {
    const allowed = role === 'admin' || role === 'manager' || role === 'operator';
    if (!allowed) {
      const url = new URL('/login', req.url);
      url.searchParams.set('next', pathname);
      return NextResponse.redirect(url);
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    '/((?!_next|static|assets).*)'
  ]
};
