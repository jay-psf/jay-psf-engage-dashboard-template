import { NextRequest, NextResponse } from "next/server";

export async function POST(req: NextRequest) {
  const { role, brand } = await req.json();

  // Validação mínima de demo
  if (role !== "admin" && role !== "sponsor") {
    return NextResponse.json({ ok: false, error: "invalid role" }, { status: 400 });
  }

  const res = NextResponse.json({ ok: true });

  // 7 dias
  res.cookies.set("role", role, { httpOnly: true, sameSite: "lax", path: "/", maxAge: 60*60*24*7 });
  if (role === "sponsor") {
    res.cookies.set("brand", brand || "heineken", { httpOnly: true, sameSite: "lax", path: "/", maxAge: 60*60*24*7 });
  } else {
    res.cookies.set("brand", "", { path: "/", maxAge: 0 });
  }

  return res;
}
