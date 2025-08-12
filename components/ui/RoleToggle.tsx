"use client";
import { useEffect } from "react";

type Props = {
  value: "admin" | "sponsor";
  onChange: (v: "admin" | "sponsor") => void;
};
export default function RoleToggle({ value, onChange }: Props) {
  const isSponsor = value === "sponsor";
  useEffect(()=>{},[value]);

  return (
    <div className="w-full max-w-[380px] mx-auto">
      <div className="relative h-12 rounded-2xl bg-[var(--surface)] border border-[var(--borderC)]">
        <div
          className="absolute top-1 bottom-1 w-[calc(50%-6px)] rounded-xl bg-[var(--card)] shadow-[var(--elev)] transition-transform"
          style={{ transform: `translateX(${isSponsor ? "calc(100% + 12px)" : "12px"})` }}
          aria-hidden
        />
        <div className="relative z-10 grid grid-cols-2 h-full text-sm font-medium">
          <button
            type="button"
            className={`rounded-xl transition-colors ${!isSponsor ? "text-[var(--text)]" : "text-[var(--muted)]"}`}
            onClick={()=>onChange("admin")}
          >
            Admin
          </button>
          <button
            type="button"
            className={`rounded-xl transition-colors ${isSponsor ? "text-[var(--text)]" : "text-[var(--muted)]"}`}
            onClick={()=>onChange("sponsor")}
          >
            Patrocinador
          </button>
        </div>
      </div>
    </div>
  );
}
