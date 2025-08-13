#!/usr/bin/env bash
set -euo pipefail

echo "== Descobrindo patches pendentes =="

# Lista números dos scripts de patch (ordenados e únicos)
SCRIPTS_NUMS=$(ls -1 apply_patch_*.sh 2>/dev/null \
  | sed -nE 's/.*_([0-9]+)\.sh/\1/p' \
  | LC_ALL=C sort -n -u)

# Lista números já comitados (mensagens contendo "patch <num>")
COMMIT_NUMS=$(git log --pretty='%s' \
  | sed -nE 's/.*patch[^0-9]*([0-9]+).*/\1/ip' \
  | tr '[:upper:]' '[:lower:]' \
  | LC_ALL=C sort -n -u)

# Calcula pendentes manualmente (sem 'comm' para evitar ruído)
PENDING=()
for n in $SCRIPTS_NUMS; do
  if ! echo "$COMMIT_NUMS" | grep -qx "$n"; then
    PENDING+=("$n")
  fi
done

if [ ${#PENDING[@]} -eq 0 ]; then
  echo "✔ Sem patches pendentes."
  exit 0
fi

echo "Patches pendentes: ${PENDING[*]}"

BATCH_SIZE=5
COUNT=0

for n in "${PENDING[@]}"; do
  sh="apply_patch_${n}.sh"
  if [ ! -f "$sh" ]; then
    echo "(!) Script $sh não encontrado — pulando."
    continue
  fi
  chmod +x "$sh" || true

  echo
  echo "== Aplicando $sh =="
  "./$sh"

  # Versiona o que o patch modificou
  git add -A
  git commit -m "patch(${n}): apply ${sh}" || true

  COUNT=$((COUNT+1))
  if [ $((COUNT % BATCH_SIZE)) -eq 0 ]; then
    echo
    echo "-- Build após ${COUNT} patches --"
    pnpm build || { echo "❌ Build falhou após ${COUNT} patches. Interrompendo."; exit 1; }
  fi
done

echo
echo "-- Build final --"
pnpm build

echo "✔ Todos os patches aplicados e build OK."
