"use client";
import * as React from "react";

type Opt = { value: string; label: string };
type Props = {
  value: string;
  onChange: (v: string) => void;
  options: Opt[];
};

export default function ToggleTabs({ value, onChange, options }: Props) {
  return (
    <div className="relative grid grid-cols-2 rounded-full border border-[var(--borderC)] bg-[var(--surface)] p-1">
      {options.map((o) => {
        const active = o.value === value;
        return (
          <button
            key={o.value}
            type="button"
            onClick={() => onChange(o.value)}
            className={`rounded-full px-4 py-1.5 text-sm transition glow-iris ${
              active ? "bg-[var(--accent)] text-white" : "bg-[var(--card)]"
            }`}
            aria-pressed={active}
          >
            {o.label}
          </button>
        );
      })}
    </div>
  );
}
