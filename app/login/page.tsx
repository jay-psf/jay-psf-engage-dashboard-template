import { Suspense } from "react";
import LoginForm from "./login-form";

export const dynamic = "force-dynamic";

export default function LoginPage() {
  return (
    <Suspense fallback={<div className="p-6">Carregando…</div>}>
      <LoginForm />
    </Suspense>
  );
}
