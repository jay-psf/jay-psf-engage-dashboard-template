"use client";
export default function ChartSpark({ data, height=44 }:{ data:number[]; height?:number }){
  if (!data || data.length < 2) return null;
  const max = Math.max(...data);
  const min = Math.min(...data);
  const h = height;
  const w = 160;
  const step = w / (data.length - 1);
  const points = data.map((y,i)=>{
    const ny = max===min ? h/2 : h - ((y - min)/(max - min))*h;
    return `${i*step},${ny}`;
  }).join(" ");
  return (
    <svg width={w} height={h} viewBox={`0 0 ${w} ${h}`} className="block">
      <polyline points={points} fill="none" stroke="currentColor" strokeWidth="2" opacity=".9" />
    </svg>
  );
}
