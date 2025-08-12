import { NextResponse } from 'next/server';

export async function POST(req: Request) {
  const res = NextResponse.redirect(new URL('/', req.url));
  res.cookies.set('role', '', { maxAge: 0 });
  res.cookies.set('brand', '', { maxAge: 0 });
  return res;
}
