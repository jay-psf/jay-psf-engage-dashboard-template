set -euo pipefail
echo "== Fix: Button variant 'primary' -> 'solid' em Settings =="

files=(
  "app/settings/page.tsx"
  "app/sponsor/[brand]/settings/page.tsx"
)

for f in "${files[@]}"; do
  if [ -f "$f" ]; then
    sed -i 's/?"primary":"outline"/?"solid":"outline"/g' "$f"
    echo "  - atualizado: $f"
  else
    echo "  - arquivo não existe: $f (ok se não houver Settings para sponsor ainda)"
  fi
done

echo "== Build =="
pnpm build
