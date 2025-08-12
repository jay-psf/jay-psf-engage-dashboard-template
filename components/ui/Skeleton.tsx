"use client";
import React from "react";
export default function Skeleton({ className }: { className?: string }){
  return (
    <div className={["animate-pulse bg-[color-mix(in_oklab,white_8%,transparent)] dark:bg-[rgba(255,255,255,.06)] rounded-xl", className].join(" ")} />
  );
}
