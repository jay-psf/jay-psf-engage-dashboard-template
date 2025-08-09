'use client';
import { useData } from "../store/useData";
import { KpiCard } from "../components/KpiCard";
import { SimpleChart } from "../components/SimpleChart";
import { Money } from "../lib/format";

export default function Page() {
  const { totals, chartSeries } = useData();
  return (
    <div className="space-y-6">
      <section className="grid grid-cols-1 md:grid-cols-3 gap-3">
        <KpiCard label="Receita Booked (YTD)" value={Money(totals.revenueYTD)} delta={totals.revenueDelta} />
        <KpiCard label="Win Rate" value={`${(totals.winRate*100).toFixed(1)}%`} delta={totals.winRateDelta} />
        <KpiCard label="Ativações em Execução" value={String(totals.activationsInFlight)} delta={totals.onTimePct} suffix="% On-time" />
      </section>
      <section className="card">
        <div className="text-sm font-semibold mb-3">Receita por mês (mock)</div>
        <SimpleChart data={chartSeries} xKey="month" yKey="revenue" />
      </section>
    </div>
  );
}
