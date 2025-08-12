"use client";

import { useState } from "react";
import Button from "@/components/ui/Button";

export default function ForgotPasswordPage(){
  const [email, setEmail] = useState("");
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent){
    e.preventDefault();
    if (!email) return;
    try{
      setLoading(true);
      // API fictícia por enquanto; só para fluir o build/UX
      await new Promise(r => setTimeout(r, 600));
      setSent(true);
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="min-h-[70vh] grid place-items-center p-6">
      <div className="w-full max-w-md rounded-2xl bg-[var(--card)] border border-[var(--borderC)] p-6 shadow-soft animate-[fadeIn_.3s_ease]">
        <h1 className="text-xl font-semibold mb-1">Esqueci minha senha</h1>
        <p className="text-sm text-[var(--muted)] mb-4">
          Digite seu e-mail para enviarmos um link de redefinição.
        </p>

        {sent ? (
          <div className="rounded-xl border border-[var(--borderC)] bg-[var(--surface)] p-4">
            <p>Se existir uma conta para <strong>{email}</strong>, você receberá um link de recuperação.</p>
            <a href="/login" className="inline-block mt-3 text-[var(--accent)] underline">Voltar ao login</a>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm mb-1">E‑mail</label>
              <input
                type="email"
                required
                value={email}
                onChange={(e)=>setEmail(e.target.value)}
                placeholder="voce@empresa.com"
                className="input"
              />
            </div>
            <div className="flex gap-3 pt-1">
              <Button type="submit" disabled={loading}>
                {loading ? "Enviando…" : "Enviar link"}
              </Button>
              <a href="/login" className="btn btn-outline">Cancelar</a>
            </div>
          </form>
        )}
      </div>
    </main>
  );
}
