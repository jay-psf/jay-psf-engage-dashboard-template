"use client";
import { useEffect, useState } from "react";

type ThemePref = "light" | "dark" | "system";

export default function SettingsPage() {
  const [pref, setPref] = useState<ThemePref>("system");

  useEffect(() => {
    const stored = (localStorage.getItem("theme") as ThemePref) || "system";
    setPref(stored);
  }, []);

  function applyTheme(next: ThemePref) {
    localStorage.setItem("theme", next);
    setPref(next);
    const m = window.matchMedia("(prefers-color-scheme: dark)");
    const effective = next === "system" ? (m.matches ? "dark" : "light") : next;
    const html = document.documentElement;
    if (effective === "dark") html.setAttribute("data-theme","dark");
    else html.removeAttribute("data-theme");
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold">Settings</h1>

      <section className="bg-card border border-border rounded-2xl shadow-soft p-6">
        <h2 className="text-lg font-semibold">Aparência</h2>
        <p className="text-sm text-muted mt-1">
          Escolha como o Engage deve se ajustar ao seu tema.
        </p>

        <div className="mt-4 flex flex-wrap gap-3">
          {(["light","dark","system"] as ThemePref[]).map(opt => (
            <button
              key={opt}
              onClick={() => applyTheme(opt)}
              className={`btn ${pref===opt ? "btn-primary" : "btn-outline"}`}
            >
              {opt === "light" ? "Light" : opt === "dark" ? "Dark" : "System"}
            </button>
          ))}
        </div>
      </section>
    </div>
  );
}
