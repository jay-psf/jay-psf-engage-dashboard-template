"use client";
import { cn } from "@/lib/cn";
import React from "react";

type Variant = "primary" | "outline" | "ghost";
type Size = "sm" | "md" | "lg";

const base = "inline-flex items-center justify-center font-medium rounded-2xl hover-lift pressable focus-visible:outline-none";
const sizes: Record<Size,string> = {
  sm: "h-9 px-3 text-sm",
  md: "h-11 px-4 text-sm",
  lg: "h-12 px-6 text-base",
};
const variants: Record<Variant,string> = {
  primary: "bg-[var(--accent)] text-white shadow-soft glow-iris hover:shadow-[var(--elev-strong)]",
  outline: "border border-border bg-transparent text-[var(--text)] hover:bg-[var(--surface)]",
  ghost: "text-[var(--text)] hover:bg-[var(--surface)]",
};

export default function Button(
  { className, variant="primary", size="md", ...rest }:
  React.ButtonHTMLAttributes<HTMLButtonElement> & { variant?: Variant; size?: Size }
){
  return <button className={cn(base, sizes[size], variants[variant], className)} {...rest} />;
}
