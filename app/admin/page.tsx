"use client";

import Section from "@/components/ui/Section";
import Card from "@/components/ui/Card";
import Metric from "@/components/ui/Metric";
import ChartSpark from "@/components/ui/ChartSpark";

export default function AdminHome(){
  return (
    <div className="container-xl">
      <Section
        title="Visão geral"
        caption="Acompanhe indicadores dos projetos e da operação."
      />

      <div className="grid-g grid-3 mb-5">
        <Card><Metric label="Projetos ativos" value="24" /></Card>
        <Card><Metric label="Patrocinadores" value="12" /></Card>
        <Card><Metric label="Receita (Mês)" value="R$ 842k" /></Card>
      </div>

      <div className="grid-g grid-2">
        <Card title="Pipeline" subtitle="Entradas nas últimas 8 semanas">
          <div className="flex items-center justify-between">
            <ChartSpark data={[2,3,3,4,6,7,9,12]} />
            <div className="text-[13px] text-[var(--muted)]">+38% vs período anterior</div>
          </div>
        </Card>

        <Card title="Performance de entregas" subtitle="SLA médio por projeto">
          <div className="flex items-center justify-between">
            <ChartSpark data={[7,7,6,6,5,5,4,4]} />
            <div className="text-[13px] text-[var(--muted)]">Melhora constante</div>
          </div>
        </Card>
      </div>
    </div>
  );
}
