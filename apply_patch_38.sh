set -euo pipefail
echo "== Patch 38: Material glass + foco visível =="

# 1) Utilitários de material/blur e focus ring
awk '1; END{
print "";
print "/* Glass utilities */";
print ".glass{";
print "  background: rgba(255,255,255,.65);";
print "  -webkit-backdrop-filter: saturate(1.6) blur(12px);";
print "  backdrop-filter: saturate(1.6) blur(12px);";
print "  border:1px solid rgba(16,24,40,.10);";
print "}";
print ":root[data-theme=\x22dark\x22] .glass{";
print "  background: rgba(13,18,32,.55);";
print "  border-color: rgba(255,255,255,.10);";
print "}";
print "";
print "/* Focus ring acessível */";
print ".focus-ring:focus-visible{ outline: none; box-shadow: 0 0 0 4px rgba(126,58,242,.35); }";
}' styles/tokens.css > styles/tokens.css.tmp && mv styles/tokens.css.tmp styles/tokens.css

echo "== Build =="
pnpm build
