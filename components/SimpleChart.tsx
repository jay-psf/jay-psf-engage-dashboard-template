'use client';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export function SimpleChart({ data, xKey, yKey }:{ data:any[]; xKey:string; yKey:string }){
  return (
    <div style={{width:'100%', height:320}}>
      <ResponsiveContainer>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey={xKey} />
          <YAxis />
          <Tooltip />
          <Line type="monotone" dataKey={yKey} dot={false} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
