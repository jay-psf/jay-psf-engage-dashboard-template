import { NextResponse } from "next/server";

export async function POST(req: Request) {
  const form = await req.formData();
  const role = String(form.get("role") || "");
  const username = String(form.get("username") || "");
  const password = String(form.get("password") || "");
  const brand = String(form.get("brand") || "");
  const next = String(form.get("next") || "/");

  let ok = false;
  let redirectTo = "/login?err=1";

  if (role === "admin") {
    // admin / 123456
    if (username.toLowerCase() === "admin" && password === "123456") {
      ok = true;
      redirectTo = "/";
    }
  } else if (role === "sponsor") {
    // sponsor / 000000
    if (username.toLowerCase() === "sponsor" && password === "000000" && brand.trim().length > 0) {
      ok = true;
      redirectTo = `/sponsor/${encodeURIComponent(brand)}/overview`;
    }
  }

  if (!ok) {
    return NextResponse.redirect(new URL("/login?err=1", req.url));
  }

  const res = NextResponse.redirect(new URL(redirectTo || next || "/", req.url));
  res.cookies.set("engage_role", role, { path: "/", httpOnly: false });
  res.cookies.set("engage_user", username, { path: "/", httpOnly: false });

  if (role === "sponsor") {
    res.cookies.set("engage_brand", brand, { path: "/", httpOnly: false });
  } else {
    res.cookies.delete("engage_brand");
  }

  return res;
}
