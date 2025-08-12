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
