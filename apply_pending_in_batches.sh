#!/usr/bin/env bash
set -euo pipefail

# 1) Calcular pendentes (scripts x commits)
PENDING=$(LC_ALL=C comm -23 \
  <(ls -1 apply_patch_*.sh 2>/dev/null | sed -nE 's/.*_([0-9]+)\.sh/\1/p' | sort -n -u) \
  <(git log --pretty='%s' | sed -nE 's/.*patch[^0-9]*([0-9]+).*/\1/ip' | sort -n -u))

if [ -z "$PENDING" ]; then
  echo "Sem patches pendentes. ✔"
  exit 0
fi

echo "Patches pendentes: $PENDING"

# 2) Aplique em lotes pequenos (5 por vez) para facilitar o rollback mental
BATCH_SIZE=5
arr=($PENDING)
total=${#arr[@]}

for ((i=0; i<total; i+=BATCH_SIZE)); do
  echo
  echo "== LOTE $(($i+1))..$(($i+BATCH_SIZE)) =="
  for ((j=i; j<i+BATCH_SIZE && j<total; j++)); do
    n="${arr[$j]}"
    sh="apply_patch_${n}.sh"
    [ -x "$sh" ] || chmod +x "$sh"
    echo "-- aplicando $sh"
    ./"$sh"
    git add -A
    git commit -m "patch(${n}): apply ${sh}" || true
  done
  echo "-- build após o lote --"
  pnpm build || { echo "❌ build falhou após lote. Parei aqui."; exit 1; }
done

echo
echo "✔ Todos os patches pendentes aplicados e build OK."
