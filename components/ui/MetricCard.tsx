"use client";
import React from "react";

export default function MetricCard(
  { title, value, footer }: { title: string; value: string; footer?: string }
){
  return (
    <div className="bg-card border border-border rounded-2xl p-4 shadow-soft hover-lift">
      <div className="text-sm text-muted">{title}</div>
      <div className="mt-2 text-2xl font-semibold">{value}</div>
      {footer && <div className="text-xs text-muted mt-3">{footer}</div>}
    </div>
  );
}
