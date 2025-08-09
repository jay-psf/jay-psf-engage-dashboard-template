'use client';
import { create } from 'zustand';
import { ColumnDef } from '@tanstack/react-table';

type Opp = { id:string; brand:string; stage:string; value:number; owner:string; createdAt:string };
type Act = { id:string; contract:string; phase:string; onTime:boolean; nps?:number };

type State = {
  opportunities: Opp[];
  activations: Act[];
  totals: { revenueYTD:number; revenueDelta:number; winRate:number; winRateDelta:number; activationsInFlight:number; onTimePct:number };
  chartSeries: { month:string; revenue:number }[];
  opportunitiesColumns: ColumnDef<Opp, any>[];
  activationsColumns: ColumnDef<Act, any>[];
};

const months = ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"];

// PRNG determinístico (mesmos números no server e no client)
function makeRng(seed = 42){
  let s = seed >>> 0;
  return () => {
    s = (s * 1664525 + 1013904223) >>> 0;
    return s / 0x100000000;
  };
}
const rng = makeRng(42);

function pick<T>(arr:T[]) { return arr[Math.floor(rng()*arr.length)]; }
function randint(min:number, max:number){ return Math.floor(min + rng()*(max-min+1)); }

function genData(): State {
  const opportunities: Opp[] = Array.from({length: 30}).map((_,i)=>{
    const stages = ["Prospecção","Qualificado","Proposta","Negociação","Fechado-Ganho","Fechado-Perdido"];
    const stage = pick(stages);
    return {
      id: `OPP-${i+1}`,
      brand: ["Skylark","Orion","Bonsai","Atlas"][i%4],
      stage,
      value: randint(20000, 170000),
      owner: ["Ana","Bruno","Carla","Diego"][i%4],
      createdAt: new Date(2025, randint(0,7), randint(1,28)).toISOString().slice(0,10)
    };
  });

  const activations: Act[] = Array.from({length: 12}).map((_,i)=>({
    id:`ACT-${i+1}`,
    contract:`CTR-${1000+i}`,
    phase:["Planejamento","Aprovações","Produção","Operação","Pós"][i%5],
    onTime: rng() > 0.25,
    nps: rng()>0.3 ? randint(6,10) : undefined
  }));

  const revenueByMonth = months.map((m,idx)=>({ month:m, revenue: 100_000 + (idx*12_500) + randint(0,50_000) }));

  const won = opportunities.filter(o=>o.stage==="Fechado-Ganho").length;
  const lost = opportunities.filter(o=>o.stage==="Fechado-Perdido").length;
  const winRate = won / Math.max(1, (won+lost));
  const onTimePct = activations.filter(a=>a.onTime).length / activations.length;

  return {
    opportunities,
    activations,
    totals: {
      revenueYTD: revenueByMonth.reduce((s,x)=>s+x.revenue,0),
      revenueDelta: 0.12,
      winRate,
      winRateDelta: 0.03,
      activationsInFlight: activations.length,
      onTimePct: onTimePct,
    },
    chartSeries: revenueByMonth,
    opportunitiesColumns: [
      { header:'#', accessorKey:'id' },
      { header:'Marca', accessorKey:'brand' },
      { header:'Estágio', accessorKey:'stage' },
      { header:'Valor (R$)', accessorKey:'value', cell:(info)=> Intl.NumberFormat('pt-BR',{style:'currency',currency:'BRL'}).format(info.getValue() as number)},
      { header:'Owner', accessorKey:'owner' },
      { header:'Criado em', accessorKey:'createdAt' },
    ],
    activationsColumns: [
      { header:'#', accessorKey:'id' },
      { header:'Contrato', accessorKey:'contract' },
      { header:'Fase', accessorKey:'phase' },
      { header:'On-time', accessorKey:'onTime', cell:(i)=> (i.getValue()? '✅':'⚠️') },
      { header:'NPS', accessorKey:'nps' },
    ]
  };
}

export const useData = create<State>(()=> genData());
