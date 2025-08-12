"use client";
import { useSearchParams } from "next/navigation";
import { useState } from "react";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const params = useSearchParams();
  const err = params.get("err");
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [brand, setBrand] = useState("");

  return (
    <main className="min-h-screen flex items-center justify-center bg-neutral-50 p-6">
      <div className="w-full max-w-3xl grid md:grid-cols-2 gap-6">
        <section
          onClick={() => setRole("admin")}
          className={`cursor-pointer border rounded-lg p-5 bg-white hover:shadow ${
            role === "admin" ? "ring-2 ring-neutral-900" : ""
          }`}
        >
          <h2 className="text-lg font-semibold mb-1">Perfil Interno (Admin)</h2>
          <p className="text-sm text-neutral-600">
            Acesso completo: Dashboard, Pipeline, Projetos, Admin.
          </p>
        </section>

        <section
          onClick={() => setRole("sponsor")}
          className={`cursor-pointer border rounded-lg p-5 bg-white hover:shadow ${
            role === "sponsor" ? "ring-2 ring-neutral-900" : ""
          }`}
        >
          <h2 className="text-lg font-semibold mb-1">Patrocinador</h2>
          <p className="text-sm text-neutral-600">
            Acesso ao portal do patrocinador: visão de contrato, agenda, resultados e financeiro.
          </p>
        </section>

        <form
          method="POST"
          action="/api/auth"
          className="md:col-span-2 bg-white border rounded-lg p-6"
        >
          <input type="hidden" name="role" value={role} />
          <h1 className="text-xl font-semibold mb-4">Entrar</h1>

          {err && (
            <div className="mb-4 text-sm text-danger-700 bg-danger-50 border border-danger-200 rounded p-3">
              Usuário ou senha inválidos para o perfil selecionado.
            </div>
          )}

          <div className="grid md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm mb-1">Usuário</label>
              <input
                name="username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder={role === "admin" ? "admin" : "sponsor"}
                className="w-full border rounded px-3 py-2"
                required
              />
            </div>
            <div>
              <label className="block text-sm mb-1">Senha</label>
              <input
                type="password"
                name="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder={role === "admin" ? "123456" : "000000"}
                className="w-full border rounded px-3 py-2"
                required
              />
            </div>

            {role === "sponsor" && (
              <div className="md:col-span-2">
                <label className="block text-sm mb-1">Marca</label>
                <input
                  name="brand"
                  value={brand}
                  onChange={(e) => setBrand(e.target.value)}
                  placeholder="Ex.: Aurora Drinks"
                  className="w-full border rounded px-3 py-2"
                  required
                />
              </div>
            )}
          </div>

          <div className="mt-6 flex items-center gap-3">
            <button className="bg-black text-white rounded px-4 py-2">
              Continuar
            </button>
            <div className="text-xs text-neutral-500">
              Dica: admin/123456 · sponsor/000000
            </div>
          </div>
        </form>
      </div>
    </main>
  );
}
