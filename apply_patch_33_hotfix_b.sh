set -euo pipefail
echo "== Patch 33 Hotfix B: fallback de tema em Settings =="

# 1) Admin Settings: coalesce null -> "system"
if grep -q 'setPref(getThemePref());' app/settings/page.tsx 2>/dev/null; then
  sed -i 's/setPref(getThemePref());/setPref(getThemePref() ?? "system");/' app/settings/page.tsx
fi

# 2) Sponsor Settings: coalesce null -> "system"
if grep -q 'setPref(getThemePref());' app/sponsor/[brand]/settings/page.tsx 2>/dev/null; then
  sed -i 's/setPref(getThemePref());/setPref(getThemePref() ?? "system");/' app/sponsor/[brand]/settings/page.tsx
fi

echo "== Build =="
pnpm build
