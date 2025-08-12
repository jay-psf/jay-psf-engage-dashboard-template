set -euo pipefail
echo "== Patch 35b: setThemeAttr(null, role) =="

apply() {
  f="components/ClientShell.tsx"
  test -f "$f" || { echo "Arquivo não encontrado: $f"; exit 1; }
  # troca undefined -> null na chamada do setThemeAttr
  sed -i 's/setThemeAttr(undefined, role);/setThemeAttr(null, role);/' "$f"
}

apply

echo "== Build =="
pnpm build
