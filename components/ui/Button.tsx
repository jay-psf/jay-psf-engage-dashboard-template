"use client";
import { ButtonHTMLAttributes } from "react";
import clsx from "clsx";

type Props = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "outline";
  size?: "md" | "lg";
};
export default function Button({ className, variant="primary", size="md", ...rest }: Props) {
  const base = "inline-flex items-center justify-center rounded-2xl font-medium transition focus:outline-none focus-visible:ring-4 focus-visible:ring-[var(--ring)]";
  const sizes = size==="lg" ? "h-11 px-6 text-sm" : "h-10 px-4 text-sm";
  const styles = variant==="primary"
    ? "bg-[var(--accent)] text-white hover:bg-[var(--accent-600)] active:bg-[var(--accent-700)] shadow-soft"
    : "border border-[var(--borderC)] bg-[var(--surface)]/30 text-[var(--text)] hover:bg-[var(--surface)]/60";
  return <button className={clsx(base, sizes, styles, className)} {...rest} />;
}
