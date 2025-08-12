"use client";
import clsx from "clsx";

export default function Button({
  children,
  size = "md",
  variant = "primary",
  className,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & {
  size?: "sm" | "md" | "lg";
  variant?: "primary" | "outline";
}) {
  const sizes = {
    sm: "h-9 px-3 text-xs",
    md: "h-10 px-4 text-sm",
    lg: "h-11 px-5 text-sm",
  }[size];

  const variants = {
    primary:
      "bg-[var(--accent)] text-white border border-[var(--accent-600)] hover:shadow-soft",
    outline:
      "bg-transparent text-[var(--text)] border border-border hover:shadow-soft",
  }[variant];

  return (
    <button
      className={clsx(
        "rounded-full transition focus-visible:outline-none focus-visible:ring-4",
        "focus-visible:ring-[var(--ring)]",
        sizes,
        variants,
        className
      )}
      {...props}
    >
      {children}
    </button>
  );
}
