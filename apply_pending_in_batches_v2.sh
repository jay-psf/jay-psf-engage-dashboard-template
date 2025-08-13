#!/usr/bin/env bash
set -euo pipefail

# 0) Normaliza e extrai os números dos scripts e dos commits
TMP_PATCH=.tmp_patch_nums.txt
TMP_COMM=.tmp_commit_nums.txt

# Lista todos os apply_patch_*.sh, extrai o número e ordena
ls -1 apply_patch_*.sh 2>/dev/null \
  | sed -nE 's/.*_([0-9]+)\.sh/\1/p' \
  | LC_ALL=C sort -n -u > "$TMP_PATCH" || true

# Lê mensagens de commit, extrai número após "patch", normaliza e ordena
git log --pretty='%s' \
  | sed -nE 's/.*patch[^0-9]*([0-9]+).*/\1/ip' \
  | tr '[:upper:]' '[:lower:]' \
  | LC_ALL=C sort -n -u > "$TMP_COMM" || true

echo "== Listas base =="
echo "Scripts encontrados: $(tr '\n' ' ' < "$TMP_PATCH")"
echo "Commits com patch:  $(tr '\n' ' ' < "$TMP_COMM")"
echo

# 1) Calcula pendentes (scripts que não estão em commits)
PENDING=$(LC_ALL=C comm -23 "$TMP_PATCH" "$TMP_COMM" || true)

if [ -z "${PENDING// }" ]; then
  echo "Sem patches pendentes. ✔"
  rm -f "$TMP_PATCH" "$TMP_COMM"
  exit 0
fi

echo "Patches pendentes: $PENDING"

# 2) Aplica em lotes pequenos
BATCH_SIZE=5
mapfile -t arr < <(echo "$PENDING")

total=${#arr[@]}
for ((i=0; i<total; i+=BATCH_SIZE)); do
  echo
  echo "== LOTE $(($i+1))..$(($i+BATCH_SIZE)) =="
  for ((j=i; j<i+BATCH_SIZE && j<total; j++)); do
    n="${arr[$j]}"
    sh="apply_patch_${n}.sh"
    if [ ! -f "$sh" ]; then
      echo "(!) Script $sh não encontrado — pulando."
      continue
    fi
    [ -x "$sh" ] || chmod +x "$sh"
    echo "-- aplicando $sh"
    ./"$sh"
    git add -A
    git commit -m "patch(${n}): apply ${sh}" || true
  done
  echo "-- build após o lote --"
  pnpm build || { echo "❌ build falhou após este lote. Parei aqui."; exit 1; }
done

echo
echo "✔ Todos os patches pendentes aplicados e build OK."
echo "Sugestão: git push"
rm -f "$TMP_PATCH" "$TMP_COMM"
