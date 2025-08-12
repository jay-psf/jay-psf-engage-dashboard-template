import type { Metadata } from "next";
import LoginForm from "../(auth)/login/login-form";

export const metadata: Metadata = {
  title: "Login • Engage",
};

export default function Page() {
  return (
    <main className="min-h-[calc(100vh-64px)] grid place-items-center px-4">
      <div className="w-full max-w-4xl">
        <h1 className="sr-only">Entrar</h1>
        <LoginForm />
      </div>
    </main>
  );
}
