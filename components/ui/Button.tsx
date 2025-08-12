"use client";
import clsx from "clsx";
import { ButtonHTMLAttributes } from "react";

type Props = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "solid" | "outline";
  size?: "md" | "lg";
};

export default function Button({ className, variant="solid", size="md", ...props }: Props){
  return (
    <button
      {...props}
      className={clsx(
        "inline-flex items-center justify-center rounded-full transition",
        "focus:outline-none focus-visible:ring-4",
        variant==="solid"
          ? "bg-[var(--accent)] text-white shadow-[0_6px_18px_rgba(0,167,221,.25)] hover:opacity-95"
          : "bg-transparent text-[var(--text)] border border-[var(--borderC)] hover:border-[var(--accent)]",
        size==="lg" ? "h-12 px-6 text-[15px] font-semibold" : "h-11 px-5 text-[14px] font-semibold",
        className
      )}
      style={{ boxShadow: "var(--elev)" }}
    />
  );
}
