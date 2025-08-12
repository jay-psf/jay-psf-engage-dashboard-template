"use client";
import { useEffect, useState } from "react";
import { saveThemePref, getThemePref, setThemeAttr, readSession } from "@/components/lib/session";
import Button from "@/components/ui/Button";

export default function AdminSettingsPage(){
  const { role } = readSession();
  const [pref, setPref] = useState<"light"|"dark"|"system">("system");

  useEffect(()=>{ setPref(getThemePref()); },[]);
  useEffect(()=>{ setThemeAttr(pref, role); saveThemePref(pref); },[pref, role]);

  return (
    <div className="space-y-6">
      <h1 className="text-xl font-semibold">Configurações</h1>
      <section className="bg-card border border-border rounded-2xl p-4">
        <div className="font-medium mb-2">Tema</div>
        <div className="flex gap-2">
          <Button variant={pref==="light"?"primary":"outline"} onClick={()=>setPref("light")}>Light</Button>
          <Button variant={pref==="dark"?"primary":"outline"} onClick={()=>setPref("dark")}>Dark</Button>
          <Button variant={pref==="system"?"primary":"outline"} onClick={()=>setPref("system")}>Sistema</Button>
        </div>
      </section>
    </div>
  );
}
