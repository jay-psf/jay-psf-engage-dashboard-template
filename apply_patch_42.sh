set -euo pipefail
echo "== Patch 42: ThemePicker unificado =="

mkdir -p components/settings
cat > components/settings/ThemePicker.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";
import Button from "@/components/ui/Button";
import { ThemePref, getThemePref, setThemeAttr, saveThemePref, readSession } from "@/components/lib/session";

export default function ThemePicker(){
  const { role } = readSession();
  const [pref, setPref] = useState<ThemePref>("system");

  useEffect(()=>{ setPref(getThemePref() ?? "system"); },[]);
  useEffect(()=>{ setThemeAttr(pref, role); saveThemePref(pref); },[pref, role]);

  return (
    <div className="card" style={{padding:16, display:"grid", gap:12}}>
      <h3 className="h3">Tema</h3>
      <div style={{display:"flex", gap:8, flexWrap:"wrap"}}>
        <Button variant={pref==="light"?"primary":"outline"} onClick={()=>setPref("light")}>Light</Button>
        <Button variant={pref==="dark"?"primary":"outline"} onClick={()=>setPref("dark")}>Dark</Button>
        <Button variant={pref==="system"?"primary":"outline"} onClick={()=>setPref("system")}>Sistema</Button>
      </div>
      <p className="subtle">Você pode sincronizar com o sistema ou escolher um tema fixo.</p>
    </div>
  );
}
TSX

# 2) Usa ThemePicker nas duas páginas de settings (se existirem)
if [ -f app/settings/page.tsx ]; then
  awk 'BEGIN{done=0}
  /export default/ && done==0 {print "import ThemePicker from \"@/components/settings/ThemePicker\";"; done=1}
  {print}
  ' app/settings/page.tsx > app/settings/page.tmp && mv app/settings/page.tmp app/settings/page.tsx

  if ! grep -q 'ThemePicker' app/settings/page.tsx; then
    sed -i 's/return (.*$/return (<div className="section" style="display:grid;gap:16"><ThemePicker \/><\/div>);/g' app/settings/page.tsx
  fi
fi

if [ -f app/sponsor/[brand]/settings/page.tsx ]; then
  awk 'BEGIN{done=0}
  /export default/ && done==0 {print "import ThemePicker from \"@/components/settings/ThemePicker\";"; done=1}
  {print}
  ' app/sponsor/[brand]/settings/page.tsx > app/sponsor/[brand]/settings/page.tmp && mv app/sponsor/[brand]/settings/page.tsx app/sponsor/[brand]/settings/page.tsx

  if ! grep -q 'ThemePicker' app/sponsor/[brand]/settings/page.tsx; then
    sed -i 's/return (.*$/return (<div className="section" style="display:grid;gap:16"><ThemePicker \/><\/div>);/g' app/sponsor/[brand]/settings/page.tsx
  fi
fi

echo "== Build =="
pnpm build
