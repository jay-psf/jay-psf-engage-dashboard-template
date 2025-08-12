set -euo pipefail

echo "== 1) Sessão: helper estável =="
mkdir -p components/lib
cat > components/lib/session.ts <<'TS'
"use client";

export type Role = "admin" | "sponsor";
export type Session = { role?: Role; brand?: string; username?: string };

export function readCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  const re = new RegExp("(?:^|; )" + name.replace(/([.$?*|{}()\\[\\]\\/\\+^])/g, "\\$1") + "=([^;]*)");
  const m = document.cookie.match(re);
  return m ? decodeURIComponent(m[1]) : undefined;
}

export function readSession(): Session {
  if (typeof document === "undefined") return {};
  const role = readCookie("role") as Role | undefined;
  const brand = readCookie("brand");
  const username = readCookie("username");
  return { role, brand, username };
}
TS

echo "== 2) Topbar: chip de perfil + toggle de tema + logout =="
mkdir -p components/ui
cat > components/ui/Topbar.tsx <<'TSX'
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
TSX

echo "== 3) Sidebar: menus por perfil (sem props) =="
cat > components/ui/Sidebar.tsx <<'TSX'
"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { readSession } from "@/components/lib/session";

function Item({ href, label }: { href: string; label: string }) {
  const pathname = usePathname();
  const active = pathname === href;
  return (
    <Link
      href={href}
      className={`block rounded-2xl border px-4 py-3 text-sm transition ${
        active ? "bg-accent text-white border-accent" : "bg-card border-border hover:shadow-soft"
      }`}
    >
      {label}
    </Link>
  );
}

export default function Sidebar() {
  const { role, brand } = readSession();

  if (!role) return null; // não aparece enquanto não loga

  const sponsorBase = `/sponsor/${brand ?? "acme"}`;

  const items =
    role === "sponsor"
      ? [
          { href: `${sponsorBase}/overview`, label: "Overview" },
          { href: `${sponsorBase}/results`, label: "Resultados" },
          { href: `${sponsorBase}/financials`, label: "Financeiro" },
          { href: `${sponsorBase}/events`, label: "Eventos" },
          { href: `${sponsorBase}/assets`, label: "Assets" },
          { href: `/settings`, label: "Settings" },
        ]
      : [
          { href: "/", label: "Overview" },
          { href: "/projetos", label: "Resultados" },
          { href: "/pipeline", label: "Financeiro" },
          { href: "/settings", label: "Settings" },
        ];

  return (
    <aside className="hidden md:block">
      <nav className="flex w-[260px] flex-col gap-4">
        {items.map((i) => (
          <Item key={i.href} href={i.href} label={i.label} />
        ))}
      </nav>
    </aside>
  );
}
TSX

echo "== 4) ClientShell: tema automático por papel, oculta chrome no /login =="
cat > components/ClientShell.tsx <<'TSX'
"use client";
import { useEffect, useState } from "react";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import Sidebar from "@/components/ui/Sidebar";
import { readSession } from "@/components/lib/session";

export default function ClientShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    // tema inicial por papel
    const sess = readSession();
    const mode = sess.role === "sponsor" ? "dark" : "light";
    const current = document.documentElement.getAttribute("data-theme");
    if (!current) document.documentElement.setAttribute("data-theme", mode);
    setMounted(true);
  }, []);

  if (isLogin) {
    return <main className="min-h-[calc(100vh-0px)]">{children}</main>;
  }

  if (!mounted) return null;

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

echo "== 5) Paleta roxa: tokens estáveis (dark/light) =="
mkdir -p styles
cat > styles/tokens.css <<'CSS'
:root {
  /* Light */
  --accent: #6B4EFF; /* roxo entourage */
  --accent-600: #5B3CF2;
  --accent-700: #4B2FE0;
  --bg: #F7F8FB;
  --card: #FFFFFF;
  --surface: #F2F4FA;
  --text: #0B1524;
  --muted: #667085;
  --borderC: rgba(16,24,40,0.10);
  --ring: rgba(107,78,255,.35);
  --elev: 0 10px 30px rgba(2,32,71,.08);
  --radius: 16px;
  --radius-lg: 20px;
}

:root[data-theme="dark"] {
  /* Dark */
  --accent: #8C7BFF;
  --accent-600: #7D6AFC;
  --accent-700: #6A54F0;
  --bg: #0B1220;
  --card: #0F1627;
  --surface: #0C1322;
  --text: #E6E8EC;
  --muted: #A5ADBB;
  --borderC: rgba(255,255,255,0.10);
  --ring: rgba(140,123,255,.45);
  --elev: 0 14px 36px rgba(0,0,0,.35);
}

/* Base */
html, body { background: var(--bg); color: var(--text); }

/* Utilitários */
.bg-card { background: var(--card); }
.bg-surface { background: var(--surface); }
.text-muted { color: var(--muted); }
.border { border: 1px solid var(--borderC); }
.border-border { border-color: var(--borderC); }
.rounded-xl { border-radius: var(--radius); }
.rounded-2xl { border-radius: var(--radius-lg); }
.shadow-soft { box-shadow: var(--elev); }

/* Inputs */
.input {
  height: 44px; width: 100%;
  border: 1px solid var(--borderC);
  background: var(--surface);
  border-radius: 12px;
  padding: 0 12px;
}
.input:focus {
  outline: 0;
  border-color: var(--accent);
  box-shadow: 0 0 0 4px var(--ring);
}

/* Botões básicos (fallback caso o componente Button não seja usado) */
.btn {
  height: 40px;
  padding: 0 16px;
  border-radius: 999px;
  border: 1px solid var(--borderC);
  background: var(--accent);
  color: #fff;
}
.btn:hover { filter: brightness(1.05); box-shadow: var(--elev); }
CSS

echo "== 6) Botão: arredondado e com variação roxa =="
cat > components/ui/Button.tsx <<'TSX'
"use client";
import clsx from "clsx";

export default function Button({
  children,
  size = "md",
  variant = "primary",
  className,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & {
  size?: "sm" | "md" | "lg";
  variant?: "primary" | "outline";
}) {
  const sizes = {
    sm: "h-9 px-3 text-xs",
    md: "h-10 px-4 text-sm",
    lg: "h-11 px-5 text-sm",
  }[size];

  const variants = {
    primary:
      "bg-[var(--accent)] text-white border border-[var(--accent-600)] hover:shadow-soft",
    outline:
      "bg-transparent text-[var(--text)] border border-border hover:shadow-soft",
  }[variant];

  return (
    <button
      className={clsx(
        "rounded-full transition focus-visible:outline-none focus-visible:ring-4",
        "focus-visible:ring-[var(--ring)]",
        sizes,
        variants,
        className
      )}
      {...props}
    >
      {children}
    </button>
  );
}
TSX

echo "== 7) Rebuild =="
pnpm build -s || true
