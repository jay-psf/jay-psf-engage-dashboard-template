set -euo pipefail
echo "== Patch 23: halo forte, press/hover-lift, bg gradiente e Skeleton =="

# 1) Tokens: halos, elevações e keyframes
cat > styles/tokens.css <<'CSS'
:root{
  /* Brand / Accent (roxo) */
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;

  /* Light */
  --bg:#F6F8FB; --card:#FFFFFF; --surface:#F2F4F9;
  --text:#0B1524; --muted:#667085; --borderC:rgba(16,24,40,.12);

  /* Dark */
  --bg-dark:#0B1220; --card-dark:#0F1627; --surface-dark:#0C1322;
  --text-dark:#E6E8EC; --muted-dark:#9BA3AF; --borderC-dark:rgba(255,255,255,.10);

  /* Sombras/halos */
  --elev:0 10px 30px rgba(2,32,71,.08);
  --elev-strong:0 18px 50px rgba(2,32,71,.15);
  --elev-dark:0 14px 36px rgba(0,0,0,.35);
  --ring:rgba(126,58,242,.40);
  --ring-strong:rgba(126,58,242,.70);
  --halo:0 0 0 10px var(--ring);
  --halo-strong:0 0 0 14px var(--ring-strong);

  /* Raio */
  --radius:16px; --radius-lg:22px;
}

/* Tema dark aplicado pela ClientShell via data-theme */
:root[data-theme="dark"]{
  --bg:var(--bg-dark);
  --card:var(--card-dark);
  --surface:var(--surface-dark);
  --text:var(--text-dark);
  --muted:var(--muted-dark);
  --borderC:var(--borderC-dark);
}

/* Base / gradiente sutil de fundo */
html,body{
  background: var(--bg);
  color: var(--text);
  min-height:100%;
  background-image:
    radial-gradient(1200px 600px at 10% -20%, rgba(126,58,242,.07), transparent 45%),
    radial-gradient(900px 500px at 90% -10%, rgba(126,58,242,.05), transparent 50%);
  background-attachment: fixed;
}

/* Helpers */
.bg-card{ background:var(--card); }
.bg-surface{ background:var(--surface); }
.text-muted{ color:var(--muted); }
.border{ border:1px solid var(--borderC); }
.border-border{ border-color:var(--borderC); }
.rounded-xl{ border-radius:var(--radius); }
.rounded-2xl{ border-radius:var(--radius-lg); }
.shadow-soft{ box-shadow: var(--elev); }
.shadow-strong{ box-shadow: var(--elev-strong); }

/* Motion */
@keyframes glowPulse { 0%{ box-shadow: var(--halo);} 100%{ box-shadow: var(--halo-strong);} }
@keyframes rise { from{ transform:translateY(0) scale(1); } to{ transform:translateY(-2px) scale(1.02);} }
@keyframes fadeIn { from{ opacity:0; transform:translateY(4px);} to{ opacity:1; transform:none;} }

/* Utilitários de interação */
.hover-lift{ transition:transform .2s ease, box-shadow .2s ease, filter .2s ease; }
.hover-lift:hover{ animation: rise .18s ease forwards; box-shadow: var(--elev-strong); }
.glow-hover{ transition: box-shadow .18s ease, transform .18s ease; }
.glow-hover:hover{ box-shadow: var(--halo-strong); transform: translateY(-1px) scale(1.01); }
.pressable:active{ transform: translateY(1px) scale(.99); filter:saturate(.98); }

/* Skeleton */
@keyframes skeletonPulse {
  0%{ opacity:.55 } 50%{ opacity:.85 } 100%{ opacity:.55 }
}
.skeleton{
  display:block; width:100%; height:1rem;
  border-radius:12px;
  background: linear-gradient(90deg, rgba(255,255,255,.08), rgba(255,255,255,.18), rgba(255,255,255,.08));
  animation: skeletonPulse 1.4s ease-in-out infinite;
}
:root:not([data-theme="dark"]) .skeleton{
  background: linear-gradient(90deg, rgba(12,18,32,.08), rgba(12,18,32,.18), rgba(12,18,32,.08));
}

/* Inputs (simples, sem recursos experimentais) */
.input{
  height:48px; width:100%;
  border:1px solid var(--borderC);
  background:var(--surface);
  color:var(--text);
  padding:0 12px; border-radius:14px;
  transition:border-color .15s ease, box-shadow .15s ease, background .15s ease;
}
.input:focus{ outline:none; border-color:var(--accent); box-shadow:0 0 0 2px rgba(126,58,242,.25); }
CSS

# 2) Utilitários globais (garante import dos tokens)
cat > styles/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base{
  :root{ color-scheme: light dark; }
  *{ box-sizing:border-box; }
}

@layer components{
  .btn{
    height:40px; border-radius:18px; padding:0 14px;
    display:inline-flex; align-items:center; gap:8px;
    border:1px solid var(--borderC);
    background:var(--card); color:var(--text);
    transition: box-shadow .18s ease, transform .18s ease, border-color .18s ease, background .18s ease;
  }
  .btn:hover{ box-shadow: var(--halo); transform: translateY(-1px) scale(1.01); }
  .btn:active{ transform: translateY(1px) scale(.99); }
  .btn-primary{ background: var(--accent); border-color:transparent; color:#fff; }
  .btn-primary:hover{ box-shadow: var(--halo-strong); }
  .btn-outline{ background:transparent; }
  .card{ background:var(--card); border:1px solid var(--borderC); border-radius:20px; box-shadow:var(--elev); }
}

@layer utilities{
  .fade-in{ animation: fadeIn .25s ease forwards; }
}
CSS

# 3) Button.tsx: usa hover glow/press
cat > components/ui/Button.tsx <<'TSX'
"use client";
import clsx from "clsx";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "outline";
  size?: "sm" | "md";
};

export default function Button({ variant="primary", size="md", className, ...rest }: Props){
  const base = "btn glow-hover pressable";
  const v = variant === "primary" ? "btn-primary" : "btn-outline";
  const s = size === "sm" ? "h-9 px-3 text-sm" : "h-10 px-4";
  return <button {...rest} className={clsx(base, v, s, className)} />;
}
TSX

# 4) Skeleton component (opcional usar nas telas)
mkdir -p components/ui
cat > components/ui/Skeleton.tsx <<'TSX'
export default function Skeleton({ className="" }: { className?: string }){
  return <span className={`skeleton ${className}`} />;
}
TSX

echo "== Build =="
pnpm build
echo "✅ Patch 23 aplicado."
