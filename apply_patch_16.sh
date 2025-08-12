set -euo pipefail

echo "== Patch 16: glow hover em botões + microanimações + grids fluidos =="

# 1) Adiciona glow e animações no CSS global
cat >> styles/globals.css <<'CSS'

/* ====== PATCH 16 ====== */

/* Glow no hover de botões clicáveis */
button, 
a.btn, 
.button, 
[role="button"],
.card:hover {
  transition: box-shadow 0.25s ease, transform 0.25s ease;
}

button:hover,
a.btn:hover,
.button:hover,
[role="button"]:hover {
  box-shadow: 0 0 0 3px var(--accent-600), 0 0 12px var(--accent);
  transform: translateY(-1px);
}

/* Microanimação para cards na entrada */
.card {
  animation: fadeInUp 0.4s ease forwards;
  opacity: 0;
}
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(8px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* Microanimação em links de navegação */
nav a {
  transition: color 0.2s ease, background-color 0.2s ease;
}

/* ====== Grids mais fluidos ====== */
.kpi-grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
}
.responsive-grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
}
CSS

# 2) Ajusta classes de grids nas páginas sponsor para usar a classe responsiva
for p in overview results financials events assets; do
  sed -i 's/grid-cols-1 lg:grid-cols-2/responsive-grid/' "app/sponsor/[brand]/$p/page.tsx" || true
  sed -i 's/grid-cols-1 lg:grid-cols-2 xl:grid-cols-3/responsive-grid/' "app/sponsor/[brand]/$p/page.tsx" || true
done

echo "== Build =="
pnpm build

echo "== Patch 16 aplicado com sucesso! =="
