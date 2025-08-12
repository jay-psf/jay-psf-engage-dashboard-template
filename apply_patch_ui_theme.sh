set -euo pipefail

echo "== 1) Paleta e tokens com contraste melhor =="
mkdir -p styles
cat > styles/tokens.css <<'CSS'
:root{
  /* Light (admin) */
  --accent:#00A7DD;
  --accent-ink:#03212B;
  --bg:#F3F6FA;            /* levemente azulada p/ contraste */
  --card:#FFFFFF;
  --surface:#F7FAFF;       /* topo/controles */
  --text:#0A1322;
  --muted:#5F6B7A;
  --borderC:rgba(15,23,42,.14);
  --ring:rgba(0,167,221,.35);
  --shadow:0 10px 30px rgba(2,32,71,.08);

  --radius:16px;
  --radius-lg:20px;
}

:root[data-theme="dark"]{
  /* Dark (sponsor) */
  --accent:#00A7DD;
  --accent-ink:#02141B;
  --bg:#0A111C;           /* fundo “navy” */
  --card:#0F1726;         /* cards */
  --surface:#0B1422;      /* appbar/menus */
  --text:#E7EAF0;
  --muted:#A4ADBA;
  --borderC:rgba(255,255,255,.12);
  --ring:rgba(0,167,221,.55);
  --shadow:0 14px 36px rgba(0,0,0,.35);
}

/* Base */
html,body{background:var(--bg);color:var(--text)}

/* Helpers */
.bg-card{background:var(--card)}
.bg-surface{background:var(--surface)}
.text-muted{color:var(--muted)}
.border{border:1px solid var(--borderC)}
.border-border{border-color:var(--borderC)}
.rounded-xl{border-radius:var(--radius)}
.rounded-2xl{border-radius:var(--radius-lg)}
.shadow-soft{box-shadow:var(--shadow)}

/* Inputs */
.input{
  height:44px;width:100%;
  border:1px solid var(--borderC);
  background:var(--surface);
  padding:0 12px;border-radius:12px;
  outline:none;transition:box-shadow .15s ease,border-color .15s ease,background .15s;
}
.input::placeholder{color:var(--muted)}
.input:focus{box-shadow:0 0 0 4px var(--ring);border-color:var(--accent);background:var(--card)}
CSS

echo "== 2) Globais: cards, botões e pills =="
cat > styles/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import "./tokens.css";

/* Cards */
.card{
  @apply rounded-2xl border shadow-soft;
  background: var(--card);
}

/* Botões */
.btn{
  display:inline-flex;align-items:center;gap:.6rem;justify-content:center;
  height:44px;padding:0 18px;border-radius:16px;font-weight:700;
  border:1px solid var(--borderC);background:var(--accent);color:#fff;
  box-shadow:var(--shadow);transition:filter .15s ease, transform .06s ease;
}
.btn:hover{filter:brightness(.98)}
.btn:active{transform:translateY(1px)}
.btn-outline{
  background:var(--surface);color:var(--text);
  border:1px solid var(--borderC);box-shadow:none;
}

/* Nave lateral – botões “pill” */
.nav-pill{
  display:flex;align-items:center;gap:.6rem;height:54px;
  padding:0 16px;border-radius:18px;border:1px solid var(--borderC);
  background: var(--surface); font-weight:600;
  transition:background .15s ease, box-shadow .15s ease, border-color .15s ease;
}
.nav-pill:hover{box-shadow:var(--shadow);border-color:var(--accent)}

/* Topbar */
.topbar{
  position:sticky;top:0;z-index:40;
  backdrop-filter:saturate(1.2) blur(8px);
  border-bottom:1px solid var(--borderC);
  background:color-mix(in srgb, var(--surface) 92%, transparent);
}

/* Pill de identidade / perfil */
.brand-pill{
  display:inline-flex;align-items:center;gap:.6rem;
  height:40px;padding:0 12px;border-radius:999px;border:1px solid var(--borderC);
  background:var(--card);color:var(--text);
  transition:box-shadow .15s, transform .06s;
}
.brand-pill:hover{box-shadow:var(--shadow)}
.brand-pill:active{transform:translateY(1px)}
.brand-pill .logo{
  width:22px;height:22px;border-radius:6px;object-fit:contain;background:#111;
}

/* Util */
.kbd{border:1px solid var(--borderC);padding:.15rem .4rem;border-radius:8px;background:var(--surface)}
CSS

echo "== 3) BrandPill component =="
mkdir -p components/ui
cat > components/ui/BrandPill.tsx <<'TSX'
"use client";
import Image from "next/image";

type Props = {
  brand?: string;
  username?: string;
  onClick?: () => void;
};

export default function BrandPill({ brand, username, onClick }: Props) {
  // Exibe: [logo] heineken  |  [perfil] Admin
  const text = brand ? brand.toLowerCase() : (username ?? "Perfil");
  const logoSrc = brand ? `/logos/${brand.toLowerCase()}.png` : undefined;

  return (
    <button className="brand-pill" onClick={onClick} aria-label="Perfil">
      {logoSrc ? (
        <Image src={logoSrc} alt={text} width={22} height={22} className="logo" />
      ) : (
        <span className="logo" aria-hidden />
      )}
      <span style={{ textTransform: "capitalize" }}>{text}</span>
    </button>
  );
}
TSX

echo "== 4) Topbar usa BrandPill e melhora contraste =="
# backup se existir
[ -f components/ui/Topbar.tsx ] && cp components/ui/Topbar.tsx components/ui/Topbar.backup.tsx || true

cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Link from "next/link";
import { useRouter } from "next/navigation";
import BrandPill from "./BrandPill";
import { readCookie } from "@/components/lib/session";

export default function Topbar() {
  const router = useRouter();

  const role = readCookie("role") as "admin" | "sponsor" | undefined;
  const brand = readCookie("brand") ?? undefined;

  async function logout() {
    await fetch("/api/logout", { method: "POST" });
    // volta ao login
    window.location.href = "/login";
  }

  return (
    <header className="topbar">
      <div className="mx-auto flex max-w-screen-2xl items-center justify-between gap-3 px-4 py-3">
        <div className="flex items-center gap-3">
          <Link href="/" className="font-semibold tracking-tight">
            Engage
          </Link>
          {role === "sponsor" && brand ? (
            <span className="text-muted hidden sm:inline">/ {brand}</span>
          ) : null}
        </div>

        <div className="flex items-center gap-3">
          <BrandPill
            brand={role === "sponsor" ? brand : undefined}
            username={role === "admin" ? "admin" : brand}
            onClick={() => router.push("/settings")}
          />
          <button className="btn btn-outline h-10 px-4" onClick={logout}>Sair</button>
        </div>
      </div>
    </header>
  );
}
TSX

echo "== 5) Sidebar – usa classes pill (sem mudar a navegação existente) =="
# Atualiza Sidebar se existir
if [ -f components/ui/Sidebar.tsx ]; then
  sed -i 's/className="rounded-2xl border p-2 .*"/className="rounded-2xl border p-3 bg-surface shadow-soft"/' components/ui/Sidebar.tsx || true
  sed -i 's/className="rounded-2xl border p-4.*"/className="rounded-2xl border p-4 bg-surface shadow-soft"/' components/ui/Sidebar.tsx || true
  sed -i 's/button className=".*Overview.*"/button className="nav-pill"/' components/ui/Sidebar.tsx || true
  sed -i 's/>Overview</>Overview</' components/ui/Sidebar.tsx || true
  sed -i 's/button className=".*Resultados.*"/button className="nav-pill"/' components/ui/Sidebar.tsx || true
  sed -i 's/button className=".*Financeiro.*"/button className="nav-pill"/' components/ui/Sidebar.tsx || true
  sed -i 's/button className=".*Settings.*"/button className="nav-pill"/' components/ui/Sidebar.tsx || true
fi

echo "== 6) Garantir que os cards de páginas usem .card =="
# troca bg-card/border-border isoladas por .card onde fizer sentido nas páginas sponsor
for f in app/sponsor/*/*.tsx; do
  [ -f "$f" ] || continue
  sed -i 's/className="[^"]*bg-card[^"]*"/className="card p-6"/g' "$f" || true
done

echo "== 7) Build =="
pnpm build

echo "== Patch aplicado. Pronto pra commit =="
