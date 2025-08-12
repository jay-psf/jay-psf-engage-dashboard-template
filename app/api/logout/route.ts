import { NextResponse } from "next/server";
export async function POST() {
  const res = NextResponse.json({ ok: true }, { status: 200 });
  res.cookies.set("role", "", { path: "/", maxAge: 0 });
  res.cookies.set("brand", "", { path: "/", maxAge: 0 });
  return res;
}
