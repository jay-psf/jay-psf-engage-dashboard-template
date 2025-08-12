#!/usr/bin/env bash
set -u
echo "== AUDIT: ambiente e estado =="

echo "• Node/PNPM:"
node -v || true
pnpm -v || true
echo

echo "• Branch/HEAD:"
git status -sb || true
git log --oneline --decorate --max-count=3 || true
echo

echo "• Patches existentes no diretório:"
ls -1 apply_patch_*.sh 2>/dev/null | sort -V || true
echo

echo "• Patches já comitados (número detectado nas mensagens):"
git log --pretty='%s' | sed -nE 's/.*patch[^0-9]*([0-9]+).*/\1/ip' | sort -n -u || true
echo

echo "• Patches pendentes (scripts que existem mas não aparecem no git log):"
LC_ALL=C comm -23 \
  <(ls -1 apply_patch_*.sh 2>/dev/null | sed -nE 's/.*_([0-9]+)\.sh/\1/p' | sort -n -u) \
  <(git log --pretty='%s' | sed -nE 's/.*patch[^0-9]*([0-9]+).*/\1/ip' | sort -n -u) \
  | tr '\n' ' ' ; echo
echo

echo "• Arquivos de estilo essenciais:"
for f in styles/globals.css styles/tokens.css ; do
  if [ -f "$f" ]; then echo "  - ok: $f"; else echo "  - MISSING: $f"; fi
done
echo

echo "• layout importa globals.css?"
if grep -q "globals.css" app/layout.tsx 2>/dev/null; then
  echo "  - ok: app/layout.tsx importa globals.css"
else
  echo "  - ALERTA: app/layout.tsx não importa ./globals.css"
fi
echo

# Lint, TS e Build (não falhar a auditoria se der erro — queremos ver tudo)
echo "== LINT =="
pnpm next lint 2>&1 | tee .audit_lint.log || true
echo
echo "== TSC (typecheck) =="
pnpm exec tsc -p tsconfig.json --noEmit 2>&1 | tee .audit_tsc.log || true
echo
echo "== BUILD =="
pnpm build 2>&1 | tee .audit_build.log || true
echo

echo "== RESUMO DE ERROS (grep rápido) =="
grep -E "Failed to compile|Type error|HookWebpackError|ELIFECYCLE|Error:" -n \
  .audit_lint.log .audit_tsc.log .audit_build.log 2>/dev/null || true
