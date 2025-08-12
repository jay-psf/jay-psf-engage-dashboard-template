set -euo pipefail
echo "== Patch 32 (fix): cria app/globals.css e utilitárias =="

# 1) Garante diretórios
mkdir -p app styles

# 2) Cria app/globals.css (o import abaixo referencia seus tokens)
cat > app/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Importa os tokens globais */
@import "../styles/tokens.css";

/* Reset/afinamentos mínimos */
:root, html, body {
  min-height: 100%;
}

/* Topbar “glass” — leve no light, fumê no dark */
.glass {
  position: sticky; top: 0; z-index: 40;
  -webkit-backdrop-filter: blur(12px);
  backdrop-filter: blur(12px);
  background: color-mix(in srgb, var(--bg) 70%, transparent);
  border-bottom: 1px solid var(--borderC);
}

/* Modo dark: vidro um pouco mais opaco */
:root[data-theme="dark"] .glass {
  background: color-mix(in srgb, var(--bg) 78%, transparent);
}

/* Pills do menu superior */
.top-pill {
  border-radius: 9999px;
  border: 1px solid var(--borderC);
  background: var(--surface);
  padding: 8px 14px;
  transition: transform .18s ease, box-shadow .18s ease, background .18s ease;
}
.top-pill:hover {
  transform: translateY(-1px);
  box-shadow: 0 10px 28px rgba(2,32,71,.12);
}
:root[data-theme="dark"] .top-pill {
  background: color-mix(in srgb, var(--surface) 92%, transparent);
}

/* Botão primário com halo sutil */
.btn-primary {
  border-radius: 9999px;
  background: var(--accent);
  color: white;
  padding: 10px 16px;
  transition: box-shadow .2s ease, transform .2s ease, filter .2s ease;
}
.btn-primary:hover {
  box-shadow:
    0 8px 22px rgba(126,58,242,.35),
    0 0 0 10px rgba(126,58,242,.12);
  filter: saturate(1.05);
  transform: translateY(-1px);
}

/* Ajuste dos cartões para o tema atual */
.card {
  background: var(--card);
  border: 1px solid var(--borderC);
  border-radius: 16px;
  box-shadow: 0 10px 30px rgba(2,32,71,.08);
}
:root[data-theme="dark"] .card {
  box-shadow: 0 14px 36px rgba(0,0,0,.35);
}
CSS

# 3) Garante que tokens.css existe (não sobrescreve se já estiver ok)
if [ ! -f styles/tokens.css ]; then
  cat > styles/tokens.css <<'CSS'
:root{
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;

  /* Light */
  --bg:#F6F8FB; --card:#FFFFFF; --surface:#F2F4F9;
  --text:#0B1524; --muted:#667085; --borderC:rgba(16,24,40,.12);

  /* Dark */
  --bg-dark:#0B1220; --card-dark:#0F1627; --surface-dark:#0C1322;
  --text-dark:#E6E8EC; --muted-dark:#9BA3AF; --borderC-dark:rgba(255,255,255,.10);
}
:root[data-theme="dark"]{
  --bg:var(--bg-dark); --card:var(--card-dark); --surface:var(--surface-dark);
  --text:var(--text-dark); --muted:var(--muted-dark); --borderC:var(--borderC-dark);
}
CSS
fi

# 4) Rebuild para validar
echo "== Build =="
pnpm build
