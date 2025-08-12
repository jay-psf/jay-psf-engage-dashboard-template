set -euo pipefail
echo "== Patch 35c: corrige RoleSwitch (localRole -> role) =="

F="components/ui/RoleSwitch.tsx"
test -f "$F" || { echo "Arquivo não encontrado: $F"; exit 1; }

# 1) Troca qualquer ocorrência de localRole por role
sed -i 's/\blocalRole\b/role/g' "$F"

# 2) Garante o useEffect correto (chama onChangeCb(role) e deps certas)
#   substitui a linha do useEffect inteira se existir um padrão parecido
sed -i 's/useEffect([^)]*)/useEffect(() => { onChangeCb(role); }/' "$F"
sed -i 's/\(\],\s*\)\[[^]]*\]\s*)/,[role, onChangeCb])/' "$F"

echo "== Build =="
pnpm build
