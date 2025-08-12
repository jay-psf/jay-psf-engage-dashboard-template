set -euo pipefail
echo "== Patch 37: Tipografia + Espaçamento + Container =="

mkdir -p styles

# 1) Tokens de design: tipografia e spacing
cat > styles/tokens.css <<'CSS'
:root{
  /* Brand / Accent (roxo Entourage) */
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;

  /* Light */
  --bg:#F6F8FB; --card:#FFFFFF; --surface:#F2F4F9;
  --text:#0B1524; --muted:#667085; --borderC:rgba(16,24,40,.12);

  /* Dark */
  --bg-dark:#0B1220; --card-dark:#0F1627; --surface-dark:#0C1322;
  --text-dark:#E6E8EC; --muted-dark:#9BA3AF; --borderC-dark:rgba(255,255,255,.10);

  /* Escalas tipográficas */
  --fs-xs: 12px;  --fs-sm: 13px;  --fs-base: 14px; --fs-md: 16px;
  --fs-lg: 18px;  --fs-xl: 20px;  --fs-2xl: 24px; --fs-3xl: 28px; --fs-4xl: 32px;

  /* Espaçamentos (ritmo 4/8/12/16/24/32) */
  --space-1:4px; --space-2:8px; --space-3:12px; --space-4:16px;
  --space-5:24px; --space-6:32px; --space-7:40px; --space-8:48px;

  /* Raio & sombras */
  --radius:16px; --radius-lg:22px;
  --elev:0 10px 30px rgba(2,32,71,.08);
  --elev-dark:0 14px 36px rgba(0,0,0,.35);
}
:root[data-theme="dark"]{
  --bg:var(--bg-dark); --card:var(--card-dark); --surface:var(--surface-dark);
  --text:var(--text-dark); --muted:var(--muted-dark); --borderC:var(--borderC-dark);
}

/* Base */
html,body{ background:var(--bg); color:var(--text); min-height:100%; }
body { font-size: var(--fs-base); line-height: 1.5; }

/* Tipografia utilitária */
.h1{ font-size:var(--fs-4xl); line-height:1.25; font-weight:700; letter-spacing:-0.01em; }
.h2{ font-size:var(--fs-3xl); line-height:1.28; font-weight:700; letter-spacing:-0.01em; }
.h3{ font-size:var(--fs-2xl); line-height:1.3; font-weight:600; }
.subtle{ font-size:var(--fs-sm); color:var(--muted); }

/* Contêiner e respiro */
.container{ max-width:1280px; margin:0 auto; padding-left:var(--space-5); padding-right:var(--space-5); }
.section{ padding: var(--space-6) 0; }

/* Cartões e superfícies */
.card{ background:var(--card); border:1px solid var(--borderC); border-radius:var(--radius); box-shadow:var(--elev); }
.surface{ background:var(--surface); border:1px solid var(--borderC); border-radius:var(--radius); }

/* Inputs/Buttons baseline (sem visual forte — virá nos próximos) */
.input{ height:48px; width:100%; border:1px solid var(--borderC); background:var(--surface); border-radius:12px; padding:0 14px; }
CSS

# 2) Garante import dos tokens no globals
mkdir -p styles
if [ ! -f styles/globals.css ]; then
  cat > styles/globals.css <<'CSS'
@import "./tokens.css";
* { box-sizing: border-box; }
a { color: inherit; text-decoration: none; }
img { max-width: 100%; height: auto; display: block; }
CSS
fi

# 3) Aplica container e respiro no layout principal (sem quebrar nada)
if [ -f app/layout.tsx ]; then
  cp app/layout.tsx app/layout.tsx.bak37 || true
  # insere uma wrapper .container no <body> se ainda não houver
  if ! grep -q 'className="container"' app/layout.tsx; then
    sed -i 's/<body\(.*\)>/<body\1><div className="container">/' app/layout.tsx
    sed -i 's#</body>#</div></body>#' app/layout.tsx
  fi
fi

echo "== Build =="
pnpm build
