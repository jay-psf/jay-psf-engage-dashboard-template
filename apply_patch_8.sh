set -euo pipefail

echo "== 1) Paleta: ajusta dark para cartões/superfícies totalmente escuros =="
cat > styles/tokens.css <<'CSS'
:root {
  /* Light */
  --accent: #7E3AF2;           /* roxo base */
  --accent-600: #6C2BD9;
  --accent-700: #5B21B6;
  --bg: #F6F8FB;
  --card: #FFFFFF;
  --surface: #F2F4F9;
  --text: #0B1524;
  --muted: #667085;
  --borderC: rgba(16,24,40,0.10);
  --ring: rgba(126,58,242,.35);

  --radius: 16px;
  --radius-lg: 20px;
  --elev: 0 12px 34px rgba(2,32,71,.08);
}

:root[data-theme="dark"] {
  /* Dark – tudo escuro */
  --accent: #A78BFA;           /* roxo claro para contraste no dark */
  --accent-600: #8B5CF6;
  --accent-700: #7C3AED;
  --bg: #0B0F1A;               /* canvas */
  --card: #0F1422;             /* cards escuros */
  --surface:#0C1120;           /* superfícies */
  --text: #E7E9EE;
  --muted: #9AA3B2;
  --borderC: rgba(255,255,255,0.12);
  --ring: rgba(167,139,250,.45);
  --elev: 0 14px 36px rgba(0,0,0,.55);
}

/* Base */
html, body { background: var(--bg); color: var(--text); }

/* Helpers */
.bg-card    { background: var(--card); }
.bg-surface { background: var(--surface); }
.text-muted { color: var(--muted); }
.border     { border: 1px solid var(--borderC); }
.border-border { border-color: var(--borderC); }
.rounded-xl  { border-radius: var(--radius); }
.rounded-2xl { border-radius: var(--radius-lg); }
.shadow-soft { box-shadow: var(--elev); }

/* Inputs */
.input {
  height: 48px; width: 100%;
  border: 1px solid var(--borderC);
  background: var(--surface);
  border-radius: 12px;
  padding: 0 12px;
  transition: box-shadow .15s ease, border-color .15s ease, background .15s ease;
}
.input:focus { outline: none; box-shadow: 0 0 0 4px var(--ring); }

/* Botões */
.btn {
  height: 44px; display: inline-flex; align-items: center; justify-content: center;
  border-radius: 999px; padding: 0 18px; font-weight: 600;
  transition: transform .04s ease, box-shadow .15s ease, background .15s ease;
}
.btn:active { transform: translateY(1px); }
.btn-primary {
  background: var(--accent); color: #fff;
  box-shadow: 0 10px 20px rgba(126,58,242,.20);
}
.btn-primary:hover { background: var(--accent-600); }
.btn-outline {
  background: transparent; border: 1px solid var(--borderC); color: var(--text);
}
CSS

echo "== 2) ClientShell: lê preferência de tema (light/dark/system) do localStorage =="
# Atualiza ClientShell para aplicar data-theme = 'dark'|'light' conforme preferência.
# Ele já estava setando tema por papel; agora respeita preferência do usuário.
apply_cs='components/ClientShell.tsx'
if [ -f "$apply_cs" ]; then
  cat > "$apply_cs".tmp <<'TSX'
"use client";
import { useEffect, useState } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import Sidebar from "@/components/ui/Sidebar";
import { readCookie } from "@/components/lib/session";

type ThemePref = "light" | "dark" | "system";

function resolveTheme(pref: ThemePref, fallbackByRole?: "light"|"dark") {
  if (pref === "system") {
    const m = window.matchMedia("(prefers-color-scheme: dark)");
    return m.matches ? "dark" : "light";
  }
  return pref || fallbackByRole || "light";
}

export default function ClientShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";

  // preferencia do usuário (localStorage)
  const [pref, setPref] = useState<ThemePref>("system");

  useEffect(() => {
    const stored = (localStorage.getItem("theme") as ThemePref) || "system";
    setPref(stored);

    const apply = () => {
      // papel ainda define fallback: sponsor = dark, admin = light (se system)
      const role = readCookie("role") as "sponsor"|"admin"|undefined;
      const fallback = role === "sponsor" ? "dark" : "light";
      const theme = resolveTheme(stored, fallback);
      const html = document.documentElement;
      if (theme === "dark") html.setAttribute("data-theme", "dark");
      else html.removeAttribute("data-theme");
    };

    apply();

    // atualiza se o sistema mudar quando pref=system
    const m = window.matchMedia("(prefers-color-scheme: dark)");
    const onChange = () => {
      const current = (localStorage.getItem("theme") as ThemePref) || "system";
      if (current === "system") apply();
    };
    m.addEventListener?.("change", onChange);
    return () => m.removeEventListener?.("change", onChange);
  }, []);

  if (isLogin) return <main className="min-h-[calc(100vh-64px)]">{children}</main>;

  return (
    <>
      <Topbar />
      <div className="mx-auto grid max-w-screen-2xl grid-cols-[260px,1fr] gap-6 p-6">
        <Sidebar />
        <main className="min-h-[70vh] animate-[fadeIn_.3s_ease]">{children}</main>
      </div>
    </>
  );
}
TSX
  mv "$apply_cs".tmp "$apply_cs"
fi

echo "== 3) Settings: adiciona Seletor de Tema (Light/Dark/System) =="
mkdir -p app/settings
cat > app/settings/page.tsx <<'TSX'
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
TSX

echo "== 4) Topbar: pílula de marca (logo + nome) e remove toggle antigo =="
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import { readCookie } from "@/components/lib/session";

export default function Topbar() {
  const role = typeof document !== "undefined" ? readCookie("role") : undefined;
  const brand = typeof document !== "undefined" ? readCookie("brand") : undefined;

  async function logout() {
    await fetch("/api/logout", { method: "POST" });
    window.location.href = "/login";
  }

  return (
    <header className="sticky top-0 z-30 bg-[var(--bg)]/90 backdrop-blur-lg border-b border-border">
      <div className="mx-auto max-w-screen-2xl flex items-center justify-between gap-4 px-6 py-3">
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 grid place-items-center rounded-xl bg-[var(--surface)] border border-border font-semibold">E</div>
          <span className="font-semibold">Engage</span>
        </div>

        <div className="flex items-center gap-3">
          {/* Chip da marca (aparece para sponsor) */}
          {role === "sponsor" && (
            <div className="flex items-center gap-2 rounded-full border border-border bg-[var(--surface)] px-3 py-1.5">
              <img
                src="/logos/heineken.png"
                alt={brand ?? "brand"}
                width="20" height="20"
                style="border-radius:6px; display:block"
              />
              <span className="text-sm font-medium capitalize">{brand}</span>
            </div>
          )}

          <button onClick={logout} className="btn btn-outline">Sair</button>
        </div>
      </div>
    </header>
  );
}
TSX

echo "== 5) Rebuild =="
pnpm build
