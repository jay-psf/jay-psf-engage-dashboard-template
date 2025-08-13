#!/usr/bin/env bash
set -euo pipefail

# --- helpers ---
norm_list() {
  # lê stdin, remove CR, extrai números, ordena, tira vazios
  tr -d '\r' | sed -nE 's/.*([0-9]+)/\1/p' | LC_ALL=C sort -n -u
}

disable_inner_builds() {
  local in="$1" out="$2"
  # cria uma cópia do patch com builds internos desativados
  sed -E '
    s/^\s*(pnpm|npm)\s+run\s+build.*$/echo "[batch-runner] build interno ignorado"/;
    s/^\s*pnpm\s+build.*$/echo "[batch-runner] build interno ignorado"/;
    s/^\s*next\s+build.*$/echo "[batch-runner] build interno ignorado"/;
    s/^\s*yarn\s+build.*$/echo "[batch-runner] build interno ignorado"/;
  ' "$in" > "$out"
  chmod +x "$out"
}

# --- listas base (scripts vs commits) ---
TMP_PATCH=.tmp_patch_nums.txt
TMP_COMM=.tmp_commit_nums.txt

ls -1 apply_patch_*.sh 2>/dev/null | norm_list > "$TMP_PATCH" || true
git log --pretty='%s' | tr '[:upper:]' '[:lower:]' | norm_list > "$TMP_COMM" || true

echo "== Listas base =="
echo -n "Scripts encontrados: "; tr '\n' ' ' < "$TMP_PATCH"; echo
echo -n "Commits com patch:  "; tr '\n' ' ' < "$TMP_COMM"; echo; echo

# pendentes = scripts que não estão no log
PENDING=$(LC_ALL=C comm -23 "$TMP_PATCH" "$TMP_COMM" || true)
if [ -z "${PENDING// /}" ]; then
  echo "Sem patches pendentes. ✔"
  rm -f "$TMP_PATCH" "$TMP_COMM"
  exit 0
fi

echo "Patches pendentes:"
echo "$PENDING" | sed 's/^/  • /'

# --- aplica em lotes ---
BATCH_SIZE=5
mapfile -t arr < <(echo "$PENDING")

for ((i=0; i<${#arr[@]}; i+=BATCH_SIZE)); do
  echo; echo "== LOTE $((i+1))..$((i+BATCH_SIZE)) =="

  for ((j=i; j<i+BATCH_SIZE && j<${#arr[@]}; j++)); do
    n="${arr[$j]}"
    sh="apply_patch_${n}.sh"
    if [ ! -f "$sh" ]; then
      echo "(!) Script $sh não encontrado — pulando."
      continue
    fi
    tmp=".tmp_apply_patch_${n}.sh"
    log=".patch_${n}.log"
    disable_inner_builds "$sh" "$tmp"

    echo "-- aplicando $sh (build interno desativado) -> log: $log"
    set +e
    "./$tmp" >"$log" 2>&1
    rc=$?
    set -e
    if [ $rc -ne 0 ]; then
      echo "❌ Falhou no patch $n. Veja tail do log:"
      tail -n 60 "$log" || true
      exit $rc
    fi
    git add -A
    git commit -m "patch(${n}): apply ${sh}" >/dev/null 2>&1 || true
  done

  echo "-- build após o lote --"
  if ! pnpm build 2>&1 | tee ".build_after_batch_$((i/BATCH_SIZE+1)).log"; then
    echo "❌ build falhou após este lote. Logs recentes:"
    tail -n 120 ".build_after_batch_$((i/BATCH_SIZE+1)).log" || true
    exit 1
  fi
done

echo; echo "✔ Todos os patches pendentes aplicados e build OK."
echo "Sugestão: git push"
rm -f "$TMP_PATCH" "$TMP_COMM" .tmp_apply_patch_*.sh
