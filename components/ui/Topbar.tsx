"use client";
import { useEffect, useState } from "react";
import { readSession } from "@/components/lib/session";
import Button from "@/components/ui/Button";

export default function Topbar() {
  const [{ role, brand }, setSess] = useState(readSession());
  const [theme, setTheme] = useState<"light"|"dark">("light");

  useEffect(() => {
    const s = readSession();
    setSess(s);
    const preferred: "light"|"dark" =
      s.role === "sponsor" ? "dark" : "light";
    const current = document.documentElement.getAttribute("data-theme") as "light"|"dark"|null;
    const mode = current ?? preferred;
    document.documentElement.setAttribute("data-theme", mode);
    setTheme(mode);
  }, []);

  function toggleTheme() {
    const next = theme === "dark" ? "light" : "dark";
    document.documentElement.setAttribute("data-theme", next);
    setTheme(next);
  }

  async function doLogout() {
    try {
      await fetch("/api/logout", { method: "POST" });
    } catch {}
    // limpa client-side também
    document.cookie = "role=; Max-Age=0; path=/";
    document.cookie = "brand=; Max-Age=0; path=/";
    document.cookie = "username=; Max-Age=0; path=/";
    window.location.href = "/login";
  }

  // Oculta no /login (ClientShell também oculta, isso é redundância segura)
  if (typeof window !== "undefined" && window.location.pathname === "/login") return null;

  return (
    <header className="sticky top-0 z-30 border-b border-border/70 bg-card/80 backdrop-blur supports-[backdrop-filter]:bg-card/60">
      <div className="mx-auto flex max-w-screen-2xl items-center justify-between px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="grid h-8 w-8 place-items-center rounded-xl bg-accent/15 text-accent font-semibold">E</div>
          <div className="text-sm font-semibold">Engage</div>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={toggleTheme}
            title={theme === "dark" ? "Mudar para claro" : "Mudar para escuro"}
            className="h-9 rounded-xl border border-border/70 px-3 text-xs hover:shadow-soft"
          >
            {theme === "dark" ? "Dark" : "Light"}
          </button>

          {/* Chip de perfil / marca */}
          <div className="flex items-center gap-2">
            {brand ? (
              <div className="flex items-center gap-2 rounded-full border border-border/70 bg-surface px-2.5 py-1.5">
                <img
                  src={`/logos/${brand}.png`}
                  alt={brand}
                  className="h-5 w-auto"
                />
                <span className="text-xs opacity-80">{brand}</span>
              </div>
            ) : (
              <div className="grid h-9 w-9 place-items-center rounded-full border border-border/70 bg-surface text-xs opacity-80">
                {role === "sponsor" ? "SP" : "AD"}
              </div>
            )}
          </div>

          <Button size="sm" onClick={doLogout}>Sair</Button>
        </div>
      </div>
    </header>
  );
}
