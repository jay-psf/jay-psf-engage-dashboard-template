'use client';
import { ReactNode } from 'react';

export function KpiCard({ title, value, trend, hint, intent='neutral' }: {
  title: string;
  value: ReactNode;
  trend?: { label:string; sign:'up'|'down'|'flat' };
  hint?: string;
  intent?: 'neutral'|'success'|'warning'|'danger';
}){
  const chipClass = intent==='success' ? 'chip chip--success'
    : intent==='warning' ? 'chip chip--warning'
    : intent==='danger' ? 'chip chip--danger'
    : 'chip';
  return (
    <div className="card hover-raise">
      <div className="kpi-title">{title}</div>
      <div className="flex items-baseline gap-3 mt-1">
        <div className="kpi-value">{value}</div>
        {trend && (
          <span className={chipClass}>
            {trend.sign==='up' ? '▲' : trend.sign==='down' ? '▼' : '—'} {trend.label}
          </span>
        )}
      </div>
      {hint && <div className="text-xs text-neutral-500 mt-2">{hint}</div>}
    </div>
  );
}
