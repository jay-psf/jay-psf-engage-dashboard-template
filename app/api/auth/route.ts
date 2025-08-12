import { NextResponse } from "next/server";

export async function POST(req: Request) {
  try {
    const { username, password, brand } = await req.json();

    // Admin: user=admin, pass=123456
    if (username === "admin" && password === "123456") {
      const res = NextResponse.json(
        { ok: true, redirect: "/" },
        { status: 200 }
      );
      res.cookies.set("role", "admin", { path: "/", httpOnly: false });
      res.cookies.set("brand", "", { path: "/", httpOnly: false });
      return res;
    }

    // Sponsor: user=sponsor, pass=000000 (brand obrigatório)
    if (username === "sponsor" && password === "000000" && brand) {
      const res = NextResponse.json(
        { ok: true, redirect: `/sponsor/${encodeURIComponent(brand)}/overview` },
        { status: 200 }
      );
      res.cookies.set("role", "sponsor", { path: "/", httpOnly: false });
      res.cookies.set("brand", brand, { path: "/", httpOnly: false });
      return res;
    }

    return NextResponse.json({ ok: false, message: "Credenciais inválidas" }, { status: 401 });
  } catch {
    return NextResponse.json({ ok: false, message: "Erro no login" }, { status: 400 });
  }
}
