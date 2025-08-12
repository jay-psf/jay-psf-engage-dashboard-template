"use client";
import clsx from "clsx";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "solid" | "outline";
  size?: "sm" | "md" | "lg";
};

export default function Button({ variant="solid", size="md", className, ...rest }: Props) {
  const base =
    "inline-flex items-center justify-center rounded-full font-medium transition " +
    "focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-[var(--accent)] " +
    "disabled:opacity-60 disabled:cursor-not-allowed";
  const sizes = {
    sm: "h-9 px-4 text-sm",
    md: "h-11 px-5",
    lg: "h-12 px-6 text-[15px]",
  } as const;
  const variants = {
    solid:
      "bg-[var(--accent)] text-white shadow-[0_8px_24px_rgba(16,167,221,.35)] " +
      "hover:brightness-[1.03] hover:shadow-[0_10px_28px_rgba(16,167,221,.45)] active:brightness-[.98]",
    outline:
      "border border-current/15 text-[var(--text)] bg-transparent " +
      "hover:bg-white/50 dark:hover:bg-white/5",
  } as const;

  return (
    <button
      className={clsx(base, sizes[size], variants[variant], className)}
      {...rest}
    />
  );
}
