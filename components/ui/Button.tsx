"use client";
import { forwardRef } from "react";
import clsx from "clsx";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "outline" | "ghost";
  size?: "sm" | "md" | "lg";
};

const sizes = {
  sm: "h-9 px-3 text-sm",
  md: "h-11 px-4 text-sm",
  lg: "h-12 px-6 text-base",
} as const;

const variants = {
  primary: "bg-accent text-white hover:opacity-90",
  outline: "border border-border bg-card hover:shadow-soft",
  ghost: "hover:bg-surface",
} as const;

const Button = forwardRef<HTMLButtonElement, Props>(function Button(
  { className, variant = "primary", size = "md", ...rest }, ref
) {
  return (
    <button
      ref={ref}
      className={clsx(
        "inline-flex items-center justify-center rounded-2xl transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/40",
        sizes[size],
        variants[variant],
        className
      )}
      {...rest}
    />
  );
});

export default Button;
