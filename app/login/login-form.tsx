"use client";
import { useSearchParams } from "next/navigation";
import { useState } from "react";

export default function LoginForm() {
  const params = useSearchParams();
  const next = params.get("next") || "/";
  const [role, setRole] = useState("internal");
  const [brand, setBrand] = useState("");

  return (
    <main className="min-h-screen flex items-center justify-center bg-neutral-50 p-6">
      <form method="POST" action="/api/auth" className="w-full max-w-md bg-white p-6 rounded-lg shadow">
        <h1 className="text-xl font-semibold mb-4">Entrar</h1>

        <label className="block text-sm mb-2">Perfil de acesso</label>
        <select name="role" value={role} onChange={(e)=>setRole(e.target.value)}
          className="w-full mb-4 border rounded px-3 py-2">
          <option value="internal">Interno</option>
          <option value="sponsor">Patrocinador</option>
        </select>

        {role === "sponsor" && (
          <>
            <label className="block text-sm mb-2">Marca</label>
            <input name="brand" value={brand} onChange={(e)=>setBrand(e.target.value)}
              placeholder="Ex: Aurora Drinks" className="w-full mb-4 border rounded px-3 py-2"/>
          </>
        )}

        <input type="hidden" name="next" value={next} />
        <button className="w-full bg-black text-white rounded px-4 py-2">Continuar</button>
      </form>
    </main>
  );
}
