"use client";
import { useEffect } from "react";
import type { Metadata } from "next";
import LoginForm from "./login-form";

export const metadata: Metadata = {
  title: "Login • Engage",
};

export default function Page() {
  // garante que a tela inicia “limpa”
  useEffect(() => {
    document.documentElement.removeAttribute("data-theme");
  }, []);

  return (
    <main className="min-h-screen grid place-items-center px-4 bg-[var(--bg)]">
      <div className="w-full max-w-4xl fade-in">
        <h1 className="display-font text-2xl font-semibold mb-4">Entrar</h1>
        <LoginForm />
      </div>
    </main>
  );
}
