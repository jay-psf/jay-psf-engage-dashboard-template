export function KpiCard({
  label, value, delta, suffix
}: { label:string; value:string; delta?:number; suffix?:string }){
  const good = (delta ?? 0) >= 0;
  return (
    <div className="card kpi">
      <div className="label text-xs text-neutral-500">{label}</div>
      <div className="value text-xl font-semibold">{value}</div>
      {delta !== undefined && (
        <div className={`delta text-xs ${good ? 'text-green-600' : 'text-red-600'}`}>
          {(good?'+':'')}{(delta*100).toFixed(1)}% {suffix ? `· ${suffix}` : ''}
        </div>
      )}
    </div>
  );
}
