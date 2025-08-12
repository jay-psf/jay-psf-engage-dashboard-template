import { NextResponse } from "next/server";

export async function POST(req: Request) {
  const { role, brand } = await req.json().catch(() => ({}));
  if (role !== "admin" && role !== "sponsor") {
    return NextResponse.json({ ok: false, error: "invalid role" }, { status: 400 });
  }
  const res = NextResponse.json({ ok: true });
  res.cookies.set("role", role, { httpOnly: false, path: "/" });
  if (brand) res.cookies.set("brand", brand, { httpOnly: false, path: "/" });
  return res;
}
