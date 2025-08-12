set -euo pipefail

echo "== 1) Reescrevendo CSS estável =="
mkdir -p styles

cat > styles/tokens.css <<'CSS'
:root {
  /* Light (admin) */
  --accent: #00A7DD;
  --bg: #F5F7FA;
  --card: #FFFFFF;
  --surface: #F9FBFF;
  --text: #0B1524;
  --muted: #667085;
  --borderC: rgba(16,24,40,0.10);
  --ring: rgba(0,167,221,.35);

  --radius: 16px;
  --radius-lg: 20px;
  --elev: 0 10px 30px rgba(2,32,71,.08);
}

/* Dark (sponsor) */
:root[data-theme="dark"] {
  --accent: #00A7DD;
  --bg: #0B1220;
  --card: #0F1627;
  --surface: #0C1322;
  --text: #E6E8EC;
  --muted: #9BA3AF;
  --borderC: rgba(255,255,255,0.10);
  --ring: rgba(0,167,221,.50);
  --elev: 0 14px 36px rgba(0,0,0,.35);
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
  border-radius: var(--radius);
  padding: 0 12px;
}
CSS

cat > styles/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import "./tokens.css";

/* Pequenos toques */
button:focus { outline: none; box-shadow: 0 0 0 3px var(--ring); }
CSS

echo "== 2) Topbar que mostra logo do sponsor (Heineken) =="
mkdir -p components/ui
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import { useEffect, useState } from "react";

export default function Topbar() {
  const [isSponsor, setIsSponsor] = useState(false);
  const [brand, setBrand] = useState<string | undefined>(undefined);

  useEffect(() => {
    try {
      const c = document.cookie;
      const role = (c.match(/(?:^|; )role=([^;]+)/)?.[1] || "");
      const b = (c.match(/(?:^|; )brand=([^;]+)/)?.[1] || "");
      setIsSponsor(decodeURIComponent(role) === "sponsor");
      setBrand(b ? decodeURIComponent(b) : undefined);
    } catch {}
  }, []);

  return (
    <header className="sticky top-0 z-40 bg-card border-b border-border">
      <div className="mx-auto max-w-screen-2xl h-16 px-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          {isSponsor && brand === "heineken" ? (
            <Image src="/logos/heineken.png" alt="Heineken" width={112} height={28} priority />
          ) : (
            <span className="font-semibold">Entourage • Engage</span>
          )}
        </div>
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-full bg-surface border border-border" />
        </div>
      </div>
    </header>
  );
}
TSX

echo "== 3) Root layout com script de tema antes da hidratação =="
mkdir -p app
cat > app/layout.tsx <<'TSX'
import "../styles/globals.css";
import type { Metadata } from "next";
import Topbar from "@/components/ui/Topbar";

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR">
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){
              try {
                var m = document.cookie.match(/(?:^|; )role=([^;]+)/);
                if (m && decodeURIComponent(m[1]) === 'sponsor') {
                  document.documentElement.setAttribute('data-theme','dark');
                } else {
                  document.documentElement.removeAttribute('data-theme');
                }
              } catch(e){}
            })();`,
          }}
        />
      </head>
      <body>
        <Topbar />
        <div className="mx-auto max-w-screen-2xl grid grid-cols-[260px,1fr] gap-6 p-6">
          {/* Sidebar permanece como está no seu projeto; se não existir, remova a grid */}
          <main className="min-h-[70vh] w-full">{children}</main>
        </div>
      </body>
    </html>
  );
}
TSX

echo "== 4) Garante logo Heineken =="
mkdir -p public/logos
[ -f heineken.png ] && mv -f heineken.png public/logos/heineken.png || true

echo "== 5) Limpa artefatos e builda =="
rm -rf .next static/css || true
pnpm build | tee .last_build.log

echo "== Patch aplicado! Teste: =="
echo "  • Admin:    usuario=admin   senha=123456"
echo "  • Sponsor:  usuario=sponsor senha=000000"
