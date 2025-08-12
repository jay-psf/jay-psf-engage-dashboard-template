set -euo pipefail

echo "== 1) Recriando styles/tokens.css (limpo) =="
mkdir -p styles
cat > styles/tokens.css <<'CSS'
:root{
  /* Light (admin) */
  --accent:#00A7DD;
  --bg:#F6F8FB;
  --card:#FFFFFF;
  --surface:#F9FBFF;
  --text:#0B1524;
  --muted:#667085;
  --borderC:rgba(16,24,40,0.10);
  --ring:rgba(0,167,221,.35);
  --radius:16px;
  --radius-lg:20px;
  --elev:0 10px 30px rgba(2,32,71,.08);
}
:root[data-theme="dark"]{
  /* Dark (sponsor) */
  --accent:#00A7DD;
  --bg:#0B1220;
  --card:#0F1627;
  --surface:#0C1322;
  --text:#E6E8EC;
  --muted:#9BA3AF;
  --borderC:rgba(255,255,255,0.10);
  --ring:rgba(0,167,221,.50);
  --elev:0 14px 36px rgba(0,0,0,.35);
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
.shadow-soft{box-shadow:var(--elev)}

/* Inputs util */
.input{
  height:44px;width:100%;
  border:1px solid var(--borderC);
  background:var(--surface);
  padding:0 12px;border-radius:12px;
  outline:none;transition:box-shadow .15s ease, border-color .15s ease;
}
.input:focus{box-shadow:0 0 0 4px var(--ring);border-color:var(--accent)}
CSS

echo "== 2) Recriando styles/globals.css (limpo) =="
cat > styles/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import "./tokens.css";

/* Acessibilidade de tema para browser */
:root, :root[data-theme="dark"] { color-scheme: light dark; }

/* Botões base usados no projeto (classe .btn) */
.btn{
  display:inline-flex;align-items:center;justify-content:center;
  height:44px;padding:0 16px;border-radius:14px;font-weight:600;
  border:1px solid var(--borderC);background:var(--accent);color:white;
  box-shadow:var(--elev);transition:opacity .15s ease, transform .06s ease;
}
.btn:disabled{opacity:.6}
.btn:hover{opacity:.95}
.btn:active{transform:translateY(1px)}

.btn-outline{
  background:var(--card);color:var(--text);
  border:1px solid var(--borderC);box-shadow:none;
}
CSS

echo "== 3) Garantindo que o layout importe do caminho correto =="
# se houver import "./styles/..." troca para "../styles/..."
if grep -q 'import "./styles/' app/layout.tsx 2>/dev/null; then
  sed -i 's#import "./styles/#import "../styles/#' app/layout.tsx
fi

echo "== 4) Build local para validar =="
pnpm build

echo "== Patch CSS aplicado com sucesso! =="
