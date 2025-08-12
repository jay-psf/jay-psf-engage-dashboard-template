import { NextResponse } from 'next/server';

export async function POST(req: Request) {
  const form = await req.formData();
  const role = String(form.get('role') || '');
  const brand = String(form.get('brand') || '');
  const next = String(form.get('next') || '/');

  const res = NextResponse.redirect(new URL(next, req.url));
  const maxAge = 7 * 24 * 60 * 60; // 7 dias
  if (role) res.cookies.set('role', role, { httpOnly: true, sameSite: 'lax', maxAge });
  if (brand) res.cookies.set('brand', brand, { httpOnly: true, sameSite: 'lax', maxAge });
  return res;
}
