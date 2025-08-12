"use client";
import clsx from "clsx";
import React from "react";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "solid" | "outline" | "ghost";
  size?: "md" | "lg";
};

export default function Button({ className, variant="solid", size="md", ...rest }: Props) {
  const base = "inline-flex items-center justify-center rounded-xl font-medium transition outline-none";
  const sizes = {
    md: "h-10 px-4 text-sm",
    lg: "h-11 px-6 text-base",
  } as const;
  const variants = {
    solid: "bg-[var(--accent)] text-white hover:opacity-90",
    outline: "border border-border bg-card hover:shadow-soft",
    ghost: "hover:bg-surface",
  } as const;

  return <button className={clsx(base, sizes[size], variants[variant], className)} {...rest} />;
}
