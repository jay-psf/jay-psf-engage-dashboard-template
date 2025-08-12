"use client";
import React from "react";
import clsx from "clsx";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary"|"outline"|"ghost";
  size?: "sm"|"md"|"lg";
};

export default function Button({variant="primary", size="md", className, disabled, ...rest}:Props){
  const base = "inline-flex items-center justify-center rounded-[14px] font-semibold transition border";
  const byVariant = {
    primary: "bg-[var(--accent)] text-white border-transparent hover:opacity-95 focus-visible:shadow-[0_0_0_3px_var(--ring-strong)]",
    outline: "bg-[var(--card)] text-[var(--text)] hover:shadow-soft focus-visible:shadow-[0_0_0_3px_var(--ring-strong)]",
    ghost: "text-[var(--text)] hover:bg-white/10 focus-visible:shadow-[0_0_0_3px_var(--ring-strong)]"
  }[variant];
  const bySize = { sm:"h-9 px-3 text-sm", md:"h-11 px-4", lg:"h-12 px-6 text-base" }[size];
  const state = disabled ? "opacity-60 cursor-not-allowed" : "";
  return <button className={clsx(base, byVariant, bySize, state, className)} disabled={disabled} {...rest} />;
}
