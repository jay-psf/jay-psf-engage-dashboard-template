set -euo pipefail
echo "== Patch 31 (fix): adiciona lib/cn.ts =="

# 1) util de classes
mkdir -p lib
cat > lib/cn.ts <<'TS'
export function cn(...classes: Array<string | false | null | undefined>) {
  return classes.filter(Boolean).join(" ");
}
TS

# 2) Build
echo "== Build =="
pnpm build
