set -euo pipefail
echo "== Patch 26: Glow V2 gradiente + hover/press =="

# Tokens/estilos utilitários
mkdir -p styles
cat > styles/effects.css <<'CSS'
/* Glow V2 — gradiente radial suave (roxo -> transparente) */
.glow {
  position: relative;
  isolation: isolate;
}
.glow::before{
  content:"";
  position:absolute; inset:-2px;
  border-radius: inherit;
  background:
    radial-gradient(60% 60% at 50% 15%, rgba(126,58,242,.35), rgba(126,58,242,.12) 40%, rgba(126,58,242,0) 70%),
    radial-gradient(80% 80% at 10% 110%, rgba(126,58,242,.25), rgba(126,58,242,0) 60%);
  filter: blur(10px);
  z-index:-1;
  opacity:.85;
  transition: opacity .25s ease, filter .25s ease;
}
.glow:hover::before{ opacity:1; filter: blur(14px); }

/* Hover lift + press */
.hover-lift{ transition: transform .18s ease, box-shadow .18s ease; }
.hover-lift:hover{ transform: translateY(-2px); box-shadow: var(--elev-strong); }
.pressable:active{ transform: translateY(0); box-shadow: var(--elev); }

/* Botões herdam glow suave */
button.btn.glow::before{ border-radius: 999px; }
CSS

# Garante import no globals.css (uma vez só)
if ! grep -q "@import \"./effects.css\";" styles/globals.css 2>/dev/null; then
  sed -i '1i @import "./effects.css";' styles/globals.css || echo '@import "./effects.css";' >> styles/globals.css
fi

echo "== Build =="
pnpm -s build
