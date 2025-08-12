set -euo pipefail
echo "== Patch 28: micro-interações (hover-lift, halos, fade-in) =="

# Acrescenta utilitários ao final do tokens.css
cat >> styles/tokens.css <<'CSS'

/* === micro-interactions / utilities === */
@keyframes fadeInUp {
  from { opacity:.0; transform: translateY(6px); }
  to   { opacity:1;  transform: translateY(0);   }
}
@keyframes softPulse {
  0% { opacity:.6; transform: scale(.98); }
  50%{ opacity:1;  transform: scale(1.00);}
  100%{opacity:.6; transform: scale(.98);}
}

/* aplica elevação suave em elementos com "bg-card" (cards, painéis) */
[class*="bg-card"] {
  transition: transform .18s ease, box-shadow .18s ease, border-color .18s ease;
}
[class*="bg-card"]:hover {
  transform: translateY(-2px);
  box-shadow: var(--elev-strong);
}

/* atributo opcional para entrada animada */
[data-animate="in"]{ animation: fadeInUp .28s ease both; }

/* halo sutil em foco/hover de botões e links com .glow */
.glow{ position: relative; }
.glow::after{
  content:""; position:absolute; inset:-10px;
  border-radius:inherit; pointer-events:none;
  background: radial-gradient(60% 60% at 50% 50%, rgba(126,58,242,.18), transparent 70%);
  opacity:0; transition: opacity .18s ease;
  filter: blur(6px);
}
.glow:is(:hover,:focus-visible)::after{ opacity:1; }

/* badge/ponto pulsante, usar class="spark" */
.spark{
  display:inline-block; width:8px; height:8px; border-radius:999px;
  background: var(--accent); animation: softPulse 1.4s ease infinite;
}
CSS

echo "== Build =="
pnpm -s build
