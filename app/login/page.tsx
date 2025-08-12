import type { Metadata } from "next";
import LoginForm from "./login-form";

export const metadata: Metadata = { title: "Login • Engage" };

export default function Page(){
  return (
    <main className="w-full px-4 min-h-[calc(100vh-64px)] grid place-items-center">
      <div className="w-full max-w-5xl">
        <h1 className="sr-only">Entrar</h1>
        <LoginForm />
      </div>
    </main>
  );
}
