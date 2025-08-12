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
