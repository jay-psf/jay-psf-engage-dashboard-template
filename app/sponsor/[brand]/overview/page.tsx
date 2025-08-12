"use client";

import { useParams } from "next/navigation";
import Section from "@/components/ui/Section";
import Card from "@/components/ui/Card";
import Metric from "@/components/ui/Metric";
import ChartSpark from "@/components/ui/ChartSpark";

export default function SponsorOverview(){
  const { brand } = useParams<{brand:string}>();
  return (
    <div className="container-xl">
      <Section
        title={`Overview — ${brand?.toString()?.toUpperCase() || "Brand"}`}
        caption="Resultados de campanhas e saúde do patrocínio."
      />

      <div className="grid-g grid-3 mb-5">
        <Card><Metric label="Eventos ativos" value="6" /></Card>
        <Card><Metric label="Alcance (30d)" value="4,2M" /></Card>
        <Card><Metric label="ROI (estimado)" value="3,7x" /></Card>
      </div>

      <div className="grid-g grid-2">
        <Card title="Engajamento" subtitle="Últimas 12 semanas">
          <div className="flex items-center justify-between">
            <ChartSpark data={[12,14,15,13,16,18,19,22,24,23,25,28]} />
            <div className="text-[13px] text-[var(--muted)]">Alta sustentada</div>
          </div>
        </Card>

        <Card title="Custo por resultado" subtitle="Tendência de eficiência">
          <div className="flex items-center justify-between">
            <ChartSpark data={[9,9,8,8,7,7,6,6,6,5,5,5]} />
            <div className="text-[13px] text-[var(--muted)]">↓ custos, ↑ eficiência</div>
          </div>
        </Card>
      </div>
    </div>
  );
}
