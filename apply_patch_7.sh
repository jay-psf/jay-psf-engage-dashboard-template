set -euo pipefail

echo "== Ajustando app/layout.tsx para não passar props ao ClientShell =="
# 1) Troca <ClientShell role={role} brand={brand}> por <ClientShell>
sed -i 's/<ClientShell[[:space:]]*role={[^}]*}[[:space:]]*brand={[^}]*}>/<ClientShell>/' app/layout.tsx || true

# 2) Remove linhas que calculam role/brand no layout (se existirem)
sed -i '/const[[:space:]]\+role[[:space:]]*=.*/d' app/layout.tsx || true
sed -i '/const[[:space:]]\+brand[[:space:]]*=.*/d' app/layout.tsx || true

# 3) Remove import de tipos não usados (se tiver)
sed -i '/from "[@/].*session.*"/d' app/layout.tsx || true

echo "== Buildando =="
pnpm build
