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
