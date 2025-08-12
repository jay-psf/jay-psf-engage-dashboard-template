import { NextResponse } from "next/server";
import { cookies } from "next/headers";

const USERS = {
  admin:   { password: "123456", role: "admin" as const,   brand: null },
  sponsor: { password: "000000", role: "sponsor" as const, brand: "heineken" },
};

export async function POST(req: Request) {
  const { username, password } = await req.json();
  const user = (USERS as any)[username];
  if (!user || user.password !== password) {
    return NextResponse.json({ ok: false }, { status: 401 });
  }
  const res = NextResponse.json({ ok: true, role: user.role, brand: user.brand });
  res.cookies.set("role", user.role, { path: "/" });
  if (user.brand) res.cookies.set("brand", user.brand, { path: "/" });
  return res;
}
