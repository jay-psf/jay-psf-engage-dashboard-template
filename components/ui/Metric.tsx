"use client";
export default function Metric({ label, value }:{ label:string; value:string }){
  return (
    <div>
      <div className="text-[13px] text-[var(--muted)] mb-1">{label}</div>
      <div className="text-[28px] leading-none font-semibold tracking-[-0.02em]">{value}</div>
    </div>
  );
}
