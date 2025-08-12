type Props = {
  label: string;
  value: string | number;
  delta?: number;         // ex: +12.3 ou -4.1 (em %)
  goodIsUp?: boolean;     // default: true (se false, queda é bom)
  series?: number[];      // sparkline
};
function toFixedSmart(n: number) {
  const a = Math.abs(n);
  if (a >= 100) return n.toFixed(0);
  if (a >= 10)  return n.toFixed(1);
  return n.toFixed(2);
}
export default function KPI({ label, value, delta, goodIsUp = true, series }: Props) {
  // sparkline simples
  let path = "";
  if (series && series.length > 1) {
    const w = 100, h = 28;
    const min = Math.min(...series), max = Math.max(...series);
    const span = max - min || 1;
    const stepX = w / (series.length - 1);
    path = series
      .map((v, i) => {
        const x = i * stepX;
        const y = h - ((v - min) / span) * h;
        return `${i === 0 ? "M" : "L"}${x},${y}`;
      })
      .join(" ");
  }
  const isUp = delta !== undefined ? delta >= 0 : undefined;
  const good = isUp === undefined ? undefined : (isUp ? goodIsUp : !goodIsUp);
  return (
    <div className="kpi">
      <div className="kpi-label">{label}</div>
      <div className="kpi-value">{value}</div>
      <div className="flex items-center justify-between">
        <div className="kpi-trend">
          {delta !== undefined ? (
            <>
              <span aria-hidden="true">{isUp ? "↑" : "↓"}</span>
              <span className={good === undefined ? "" : (good ? "badge-pos" : "badge-neg")}>
                {toFixedSmart(delta)}%
              </span>
              <span className="text-muted"> vs. mês ant.</span>
            </>
          ) : (
            <span className="text-muted">—</span>
          )}
        </div>
        {path ? (
          <svg width="100" height="28" viewBox="0 0 100 28" fill="none" aria-hidden="true">
            <path d={path} stroke="currentColor" strokeWidth="2" opacity="0.9"/>
          </svg>
        ) : <span className="text-muted text-xs">sem dados</span>}
      </div>
    </div>
  );
}
