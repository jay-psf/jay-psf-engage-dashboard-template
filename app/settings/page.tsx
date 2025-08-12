"use client";
import { useEffect, useState } from "react";
import { saveThemePref, getThemePref, setThemeAttr, readSession } from "@/components/lib/session";
import Button from "@/components/ui/Button";

import ThemePicker from "@/components/settings/ThemePicker";
export default function AdminSettingsPage(){
  const { role } = readSession();
  const [pref, setPref] = useState<"light"|"dark"|"system">("system");

  useEffect(()=>{ setPref(getThemePref() ?? "system"); },[]);
  useEffect(()=>{ setThemeAttr(pref, role); saveThemePref(pref); },[pref, role]);

  return (
    <div className="space-y-6">
      <h1 className="text-xl font-semibold">Configurações</h1>
      <section className="bg-card border border-border rounded-2xl p-4">
        <div className="font-medium mb-2">Tema</div>
        <div className="flex gap-2">
          <Button variant={pref==="light"?"solid":"outline"} onClick={()=>setPref("light")}>Light</Button>
          <Button variant={pref==="dark"?"solid":"outline"} onClick={()=>setPref("dark")}>Dark</Button>
          <Button variant={pref==="system"?"solid":"outline"} onClick={()=>setPref("system")}>Sistema</Button>
        </div>
      </section>
    </div>
  );
}
