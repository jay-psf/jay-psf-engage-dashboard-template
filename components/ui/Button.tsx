"use client";
import clsx from "clsx";
type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "solid" | "outline" | "ghost";
  size?: "sm" | "md" | "lg";
};
export default function Button({ className, variant="solid", size="md", ...props }: Props) {
  const base = "inline-flex items-center justify-center font-medium transition-all active:scale-[.98] rounded-full";
  const sizes = {
    sm: "px-3 h-9 text-sm",
    md: "px-4 h-10 text-sm",
    lg: "px-5 h-12 text-base"
  }[size];
  const styles = {
    solid: "bg-accent text-white shadow-soft hover:bg-accent-strong",
    outline: "border border-border text-text hover:bg-surface",
    ghost: "text-text hover:bg-surface"
  }[variant];
  return <button className={clsx(base, sizes, styles, className)} {...props} />;
}
