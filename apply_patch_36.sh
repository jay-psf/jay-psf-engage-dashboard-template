set -euo pipefail
echo "== Patch 36: Overview Apple-like (tipografia, respiro, cards e sparklines) =="

# 1) tokens: pequenos utilitários de container/prosa e cards
apply_tokens () {
  cat > styles/tokens.css <<'CSS'
:root{
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;

  /* Light */
  --bg:#F6F8FB; --card:#FFFFFF; --surface:#F2F4F9;
  --text:#0B1524; --muted:#667085; --borderC:rgba(16,24,40,.12);

  /* Dark */
  --bg-dark:#0B1220; --card-dark:#0F1627; --surface-dark:#0C1322;
  --text-dark:#E6E8EC; --muted-dark:#9BA3AF; --borderC-dark:rgba(255,255,255,.10);

  --radius:16px; --radius-lg:22px;
  --elev:0 10px 30px rgba(2,32,71,.08);
  --elev-dark:0 14px 36px rgba(0,0,0,.35);
  --ring:rgba(126,58,242,.40); --ring-strong:rgba(126,58,242,.70);
}

:root[data-theme="dark"]{
  --bg:var(--bg-dark); --card:var(--card-dark); --surface:var(--surface-dark);
  --text:var(--text-dark); --muted:var(--muted-dark); --borderC:var(--borderC-dark);
}

/* fundo + tipografia base */
html,body{ background:var(--bg); color:var(--text); }
.h1{ font-weight:700; letter-spacing:-.01em; font-size: clamp(24px,3.2vw,28px); }
.h2{ font-weight:600; letter-spacing:-.01em; font-size: clamp(18px,2.6vw,22px); color:var(--muted); }

/* container confortável */
.container-xl{ max-width:1280px; margin-inline:auto; padding: 28px 28px; }
@media (min-width:1024px){ .container-xl{ padding: 36px; } }

/* card base */
.card{
  background:var(--card);
  border:1px solid var(--borderC);
  border-radius:var(--radius-lg);
  box-shadow: var(--elev);
}
:root[data-theme="dark"] .card{ box-shadow: var(--elev-dark); }

/* espaçamentos utilitários */
.grid-g{
  display:grid; gap:20px;
}
@media (min-width:1024px){
  .grid-g{ gap:24px; }
  .grid-3{ grid-template-columns: repeat(3, minmax(0,1fr)); }
  .grid-2{ grid-template-columns: repeat(2, minmax(0,1fr)); }
}

/* botões continuam com glow sutil */
.btn-glow:hover{ box-shadow: 0 0 0 8px rgba(126,58,242,.08); }
CSS
}
apply_tokens

# 2) componentes de UI
mkdir -p components/ui

# 2.1) Card genérico
cat > components/ui/Card.tsx <<'TSX'
"use client";
import { ReactNode } from "react";

export default function Card({
  title, subtitle, actions, children, className=""
}:{
  title?: string; subtitle?: string; actions?: ReactNode;
  children?: ReactNode; className?: string;
}){
  return (
    <section className={`card p-5 lg:p-6 ${className}`}>
      {(title || actions || subtitle) && (
        <header className="mb-4 flex items-start justify-between gap-3">
          <div>
            {title && <h3 className="text-[15px] font-semibold tracking-[-0.01em]">{title}</h3>}
            {subtitle && <p className="text-[13px] text-[var(--muted)] mt-0.5">{subtitle}</p>}
          </div>
          {actions}
        </header>
      )}
      <div>{children}</div>
    </section>
  );
}
TSX

# 2.2) Section (título de página)
cat > components/ui/Section.tsx <<'TSX'
"use client";
import { ReactNode } from "react";

export default function Section({
  title, caption, right, className=""
}:{ title:string; caption?:string; right?:ReactNode; className?:string }){
  return (
    <div className={`mb-5 lg:mb-6 flex items-end justify-between ${className}`}>
      <div>
        <h1 className="h1">{title}</h1>
        {caption && <p className="h2 mt-1">{caption}</p>}
      </div>
      {right}
    </div>
  );
}
TSX

# 2.3) Metric (número grande com rotulo)
cat > components/ui/Metric.tsx <<'TSX'
"use client";
export default function Metric({ label, value }:{ label:string; value:string }){
  return (
    <div>
      <div className="text-[13px] text-[var(--muted)] mb-1">{label}</div>
      <div className="text-[28px] leading-none font-semibold tracking-[-0.02em]">{value}</div>
    </div>
  );
}
TSX

# 2.4) Sparkline simples (SVG inline)
cat > components/ui/ChartSpark.tsx <<'TSX'
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
TSX

# 3) páginas: ADMIN overview reimaginado
mkdir -p app
cat > app/admin/page.tsx <<'TSX'
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
TSX

# 4) páginas: SPONSOR overview reimaginado
mkdir -p app/sponsor/[brand]/overview
cat > app/sponsor/[brand]/overview/page.tsx <<'TSX'
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
TSX

echo "== Build =="
pnpm build
