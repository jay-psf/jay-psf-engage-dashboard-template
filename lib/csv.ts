export function toCSV<T extends Record<string,any>>(rows:T[]):string{
  if(!rows.length) return "";
  const cols=Object.keys(rows[0]);
  const esc=(v:any)=>`"${String(v).replace(/"/g,'""')}"`;
  const header=cols.map(esc).join(",");
  const body=rows.map(r=>cols.map(c=>esc(r[c]??"")).join(",")).join("\n");
  return header+"\\n"+body;
}
export function downloadCSV(filename:string, csv:string){
  const blob=new Blob([csv],{type:"text/csv;charset=utf-8;"});
  const url=URL.createObjectURL(blob);
  const a=document.createElement("a");
  a.href=url; a.download=filename; a.click();
  URL.revokeObjectURL(url);
}
