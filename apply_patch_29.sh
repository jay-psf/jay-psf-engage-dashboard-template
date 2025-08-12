set -euo pipefail
echo "== Patch 29: sponsor settings com upload de logo =="

mkdir -p app/sponsor/[brand]/settings
cat > app/sponsor/[brand]/settings/page.tsx <<'TSX'
"use client";
/* eslint-disable @next/next/no-img-element */
import * as React from "react";

type ThemePref = "light" | "dark" | "system";

function getThemePref(): ThemePref {
  if (typeof window === "undefined") return "system";
  return (window.localStorage.getItem("themePref") as ThemePref) || "system";
}

export default function SponsorSettingsPage({ params }: { params: { brand: string } }) {
  const brand = params.brand?.toLowerCase() || "acme";
  const [pref, setPref] = React.useState<ThemePref>(getThemePref());
  const [preview, setPreview] = React.useState<string | null>(null);
  const [saving, setSaving] = React.useState(false);

  React.useEffect(() => {
    try {
      const v = window.localStorage.getItem(`brandLogo:${brand}`);
      if (v) setPreview(v);
    } catch {}
  }, [brand]);

  function setTheme(p: ThemePref) {
    setPref(p);
    if (typeof document !== "undefined") {
      window.localStorage.setItem("themePref", p);
      const root = document.documentElement;
      if (p === "system") {
        const m = window.matchMedia("(prefers-color-scheme: dark)");
        root.setAttribute("data-theme", m.matches ? "dark" : "light");
      } else {
        root.setAttribute("data-theme", p);
      }
    }
  }

  async function onPickFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    const okTypes = ["image/png","image/jpeg","image/webp","image/svg+xml"];
    if (!okTypes.includes(file.type)) { alert("Use PNG/JPG/WEBP/SVG."); return; }
    const reader = new FileReader();
    reader.onload = () => setPreview(String(reader.result || ""));
    reader.readAsDataURL(file);
  }

  async function onSave() {
    try {
      setSaving(true);
      if (preview) {
        window.localStorage.setItem(`brandLogo:${brand}`, preview);
      }
      alert("Preferências salvas!");
    } finally {
      setSaving(false);
    }
  }

  function onClearLogo() {
    try {
      window.localStorage.removeItem(`brandLogo:${brand}`);
      setPreview(null);
    } catch {}
  }

  return (
    <div className="space-y-6 p-6">
      <div className="rounded-2xl border border-[var(--borderC)] bg-[var(--surface)] p-4 shadow-soft" data-animate="in">
        <h2 className="text-lg font-semibold">Aparência</h2>
        <p className="text-[var(--muted)] text-sm">Escolha o tema do Engage.</p>
        <div className="mt-3 flex gap-2">
          {(["light","dark","system"] as ThemePref[]).map(v => (
            <button
              key={v}
              onClick={() => setTheme(v)}
              className={`glow rounded-full border border-[var(--borderC)] px-3 py-1.5 text-sm ${pref===v ? "bg-[var(--accent)] text-white" : "bg-[var(--card)]"}`}
            >
              {v[0].toUpperCase()+v.slice(1)}
            </button>
          ))}
        </div>
      </div>

      <div className="rounded-2xl border border-[var(--borderC)] bg-[var(--surface)] p-4 shadow-soft" data-animate="in">
        <h2 className="text-lg font-semibold">Logo do patrocinador</h2>
        <p className="text-[var(--muted)] text-sm">Envie a marca (de preferência, PNG com fundo transparente).</p>

        <div className="mt-4 flex items-center gap-16">
          <label className="glow inline-flex cursor-pointer items-center gap-3 rounded-xl border border-[var(--borderC)] bg-[var(--card)] px-4 py-2">
            <input type="file" accept="image/*" className="hidden" onChange={onPickFile} />
            <span>Selecionar arquivo…</span>
          </label>

          <div className="flex items-center gap-12">
            <div className="text-sm text-[var(--muted)]">Pré‑visualização</div>
            <div className="rounded-xl border border-[var(--borderC)] bg-[var(--card)] p-2">
              {preview ? (
                <img src={preview} alt="logo" width={88} height={88} style={{display:"block",borderRadius:12,objectFit:"cover"}} />
              ) : (
                <div className="flex h-[88px] w-[88px] items-center justify-center rounded-[12px] bg-[var(--surface)] text-xs text-[var(--muted)]">sem logo</div>
              )}
            </div>
          </div>
        </div>

        <div className="mt-4 flex gap-2">
          <button onClick={onSave} disabled={saving} className="glow rounded-full bg-[var(--accent)] px-4 py-2 text-sm text-white">
            {saving ? "Salvando…" : "Salvar"}
          </button>
          <button onClick={onClearLogo} className="glow rounded-full border border-[var(--borderC)] bg-[var(--card)] px-4 py-2 text-sm">
            Remover logo
          </button>
        </div>
      </div>
    </div>
  );
}
TSX

echo "== Build =="
pnpm -s build
