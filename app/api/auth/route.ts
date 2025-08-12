import { NextResponse } from "next/server";

export async function POST(req: Request) {
  const { username, password, role, brand } = await req.json();

  // Mock simples (vamos trocar por auth real depois)
  const okAdmin = role === "admin" && username === "admin" && password === "123456";
  const okSponsor = role === "sponsor" && username === "sponsor" && password === "000000";

  if (!okAdmin && !okSponsor) {
    return new NextResponse("unauthorized", { status: 401 });
  }

  const res = NextResponse.redirect(new URL(okSponsor ? `/sponsor/${brand || "heineken"}/overview` : "/", req.url));
  res.cookies.set("role", role, { path: "/", httpOnly: false });
  if (okSponsor) {
    res.cookies.set("brand", brand || "heineken", { path: "/", httpOnly: false });
  } else {
    res.cookies.set("brand", "", { path: "/", httpOnly: false });
  }
  return res;
}
