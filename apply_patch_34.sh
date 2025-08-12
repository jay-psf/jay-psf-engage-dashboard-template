set -euo pipefail
echo "== Patch 34: Login/Forgot como Client e sem metadata/onSubmit =="

fix_page () {
  local f="$1"
  test -f "$f" || { echo "  - skip: $f (não existe)"; return; }

  # 1) Garante "use client" no topo
  if ! grep -q '^"use client";' "$f"; then
    sed -i '1i "use client";' "$f"
  fi

  # 2) Remove export de metadata (não permitido em Client)
  sed -i '/export const metadata/,/};/d' "$f"

  # 3) Remove onSubmit passado como prop (Server->Client)
  # (somente nesta página; os componentes devem tratar o submit internamente)
  sed -i 's/onSubmit={[^}]*}//g' "$f"

  echo "  - ok: $f"
}

fix_page app/login/page.tsx
fix_page app/forgot-password/page.tsx

echo "== Build =="
pnpm build
