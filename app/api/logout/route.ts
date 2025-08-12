import { NextResponse } from "next/server";
export async function POST(req: Request) {
  const res = NextResponse.redirect(new URL("/login", req.url));
  res.cookies.delete("engage_role");
  res.cookies.delete("engage_brand");
  return res;
}
