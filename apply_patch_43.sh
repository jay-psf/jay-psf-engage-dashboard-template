set -euo pipefail
echo "== Patch 43: KPI Cards + Grid responsiva =="

mkdir -p components/ui
cat > components/ui/KpiCard.tsx <<'TSX'
"use client";

type Props = {
  label: string;
  value: string;
  delta?: string;
  icon?: string; // emoji simples
  data?: number[]; // sparkline
};
export default function KpiCard({label,value,delta,icon="📈",data=[3,4,3,5,6,7,6,8]}:Props){
  const w=120,h=32; const max=Math.max(...data), min=Math.min(...data);
  const points = data.map((v,i)=>[ (i/(data.length-1))*w, h - ((v-min)/(max-min||1))*h ]);
  const d = points.map((p,i)=> (i? "L":"M")+p[0]+","+p[1]).join(" ");

  return (
    <div className="card" style={{padding:16, display:"grid", gap:8}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
        <span className="subtle">{label}</span>
        <span aria-hidden>{icon}</span>
      </div>
      <div className="h2" style={{fontSize:24}}>{value}</div>
      <div className="subtle" style={{color:"var(--accent)"}}>{delta}</div>
      <svg width={w} height={h} aria-hidden focusable="false">
        <path d={d} fill="none" stroke="currentColor" />
      </svg>
    </div>
  );
}
TSX

# 2) Atualiza overview admin (se existir)
if [ -f app/admin/page.tsx ]; then
  cp app/admin/page.tsx app/admin/page.tsx.bak43 || true
  cat > app/admin/page.tsx <<'TSX'
"use client";
import KpiCard from "@/components/ui/KpiCard";

export default function AdminOverview(){
  return (
    <div className="section" style={{display:"grid", gap:16}}>
      <h1 className="h1">Overview</h1>
      <div style={{display:"grid", gap:16, gridTemplateColumns:"repeat(auto-fit, minmax(220px, 1fr))"}}>
        <KpiCard label="Receita MRR" value="R$ 184k" delta="+12% MoM" icon="💰" data={[3,4,5,4,6,7,8,9]} />
        <KpiCard label="Projetos ativos" value="32" delta="+3" icon="📦" data={[2,2,3,3,4,4,5,6]} />
        <KpiCard label="Patrocinadores" value="14" delta="+1" icon="🤝" data={[1,1,2,2,2,3,3,4]} />
        <KpiCard label="Satisfação" value="92%" delta="+2pp" icon="⭐" data={[80,82,85,84,88,90,92,92]} />
      </div>
    </div>
  );
}
TSX
fi

# 3) Atualiza overview sponsor (se existir)
if [ -f app/sponsor/[brand]/overview/page.tsx ]; then
  cp app/sponsor/[brand]/overview/page.tsx app/sponsor/[brand]/overview/page.tsx.bak43 || true
  cat > app/sponsor/[brand]/overview/page.tsx <<'TSX'
"use client";
import KpiCard from "@/components/ui/KpiCard";

export default function SponsorOverview(){
  return (
    <div className="section" style={{display:"grid", gap:16}}>
      <h1 className="h1">Overview do Patrocinador</h1>
      <div style={{display:"grid", gap:16, gridTemplateColumns:"repeat(auto-fit, minmax(220px, 1fr))"}}>
        <KpiCard label="Investimento Total" value="R$ 2,4M" delta="+8% YoY" icon="🏦" data={[5,4,6,7,6,7,8,9]} />
        <KpiCard label="Eventos Ativos" value="7" delta="+2" icon="🎪" data={[2,3,3,4,4,5,6,7]} />
        <KpiCard label="ROI estimado" value="3.2x" delta="+0.3x" icon="📊" data={[2.5,2.6,2.7,2.8,3.0,3.1,3.2,3.2]} />
      </div>
    </div>
  );
}
TSX
fi

echo "== Build =="
pnpm build
