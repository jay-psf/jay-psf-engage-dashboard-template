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
        <Button variant={pref==="light"?"solid":"outline"} onClick={()=>setPref("light")}>Light</Button>
        <Button variant={pref==="dark"?"solid":"outline"} onClick={()=>setPref("dark")}>Dark</Button>
        <Button variant={pref==="system"?"solid":"outline"} onClick={()=>setPref("system")}>Sistema</Button>
      </div>
      <p className="subtle">Você pode sincronizar com o sistema ou escolher um tema fixo.</p>
    </div>
  );
}
