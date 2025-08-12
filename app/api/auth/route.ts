import { NextResponse } from "next/server";

export async function POST(req: Request) {
  const form = await req.formData();
  const role = String(form.get("role") || "internal");
  const brand = String(form.get("brand") || "");
  const next = String(form.get("next") || "/");

  // cookies básicos (mock de sessão)
  const res = NextResponse.redirect(new URL(
    role === "sponsor"
      ? `/sponsor/${encodeURIComponent(brand || "Aurora Drinks")}/overview`
      : next || "/",
    req.url
  ));

  res.cookies.set("engage_role", role, { path: "/", httpOnly: false });
  if (role === "sponsor") {
    res.cookies.set("engage_brand", brand || "Aurora Drinks", { path: "/", httpOnly: false });
  } else {
    res.cookies.delete("engage_brand");
  }

  return res;
}
