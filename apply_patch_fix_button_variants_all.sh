set -euo pipefail
echo "== Fix global: Button 'primary' -> 'solid' =="

# variações comuns (ternário e props diretas)
find app components -type f \( -name '*.tsx' -o -name '*.ts' \) -print0 | xargs -0 sed -i \
  -e 's/?"primary":"outline"/?"solid":"outline"/g' \
  -e 's/variant="primary"/variant="solid"/g' \
  -e 's/variant={"primary"}/variant={"solid"}/g'

echo "== Build =="
pnpm build
