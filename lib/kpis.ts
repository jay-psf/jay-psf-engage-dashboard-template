export type Opp = { id:string; stage:string; value:number; createdAt:string };
export type Act = { onTime:boolean };
export function sum(arr:number[]){ return arr.reduce((a,b)=>a+b,0); }
export function isSameMonthISO(iso:string, ref=new Date()){
  const d=new Date(iso); return d.getUTCFullYear()===ref.getUTCFullYear() && d.getUTCMonth()===ref.getUTCMonth();
}
export function isSameQuarterISO(iso:string, ref=new Date()){
  const d=new Date(iso); const q=(m:number)=>Math.floor(m/3);
  return d.getUTCFullYear()===ref.getUTCFullYear() && q(d.getUTCMonth())===q(ref.getUTCMonth());
}
export function revenueYTD(opps:Opp[]){
  const now=new Date(); const y=now.getUTCFullYear();
  return sum(opps.filter(o=>new Date(o.createdAt).getUTCFullYear()===y && o.stage==="Fechado-Ganho").map(o=>o.value));
}
export function revenueMTD(opps:Opp[]){
  return sum(opps.filter(o=>isSameMonthISO(o.createdAt) && o.stage==="Fechado-Ganho").map(o=>o.value));
}
export function revenueQTD(opps:Opp[]){
  return sum(opps.filter(o=>isSameQuarterISO(o.createdAt) && o.stage==="Fechado-Ganho").map(o=>o.value));
}
export function winRate(opps:Opp[]){
  const won=opps.filter(o=>o.stage==="Fechado-Ganho").length;
  const lost=opps.filter(o=>o.stage==="Fechado-Perdido").length;
  const denom=won+lost; return denom? won/denom : 0;
}
export function onTimePct(acts:Act[]){
  if(!acts.length) return 0; return acts.filter(a=>a.onTime).length/acts.length;
}
export function forecast30d(opps:Opp[]){
  const now=Date.now(); const in30=(iso:string)=> (new Date(iso).getTime()-now) <= 1000*60*60*24*30;
  const weights:Record<string,number>={ "Prospecção":0.15,"Qualificado":0.3,"Proposta":0.55,"Negociação":0.75,"Fechado-Ganho":1,"Fechado-Perdido":0 };
  return sum(opps.filter(o=>in30(o.createdAt)).map(o=>o.value*(weights[o.stage]??0)));
}
