set -euo pipefail
echo "== Patch 39: Dark sólido calibrado =="

# Ajusta tons escuros e bordas
awk '1; END{
print "";
print "/* Dark solid cards/surfaces */";
print ":root[data-theme=\x22dark\x22] .card{ background:#0F1627; border-color:#FFFFFF1A; box-shadow:var(--elev-dark); }";
print ":root[data-theme=\x22dark\x22] .surface{ background:#0C1322; border-color:#FFFFFF1A; box-shadow:none; }";
}' styles/tokens.css > styles/tokens.css.tmp && mv styles/tokens.css.tmp styles/tokens.css

echo "== Build =="
pnpm build
