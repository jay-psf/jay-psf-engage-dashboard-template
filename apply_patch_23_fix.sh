set -euo pipefail
echo "== Patch 23-fix: Button com size lg =="

cat > components/ui/Button.tsx <<'TSX'
"use client";
import clsx from "clsx";

type Props = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "outline";
  size?: "sm" | "md" | "lg";
};

export default function Button({ variant="primary", size="md", className, ...rest }: Props){
  const base = "btn glow-hover pressable";
  const v = variant === "primary" ? "btn-primary" : "btn-outline";
  const s =
    size === "sm" ? "h-9 px-3 text-sm" :
    size === "lg" ? "h-12 px-6 text-base" :
    "h-10 px-4";
  return <button {...rest} className={clsx(base, v, s, className)} />;
}
TSX

echo "== Build =="
pnpm build
echo "✅ Button atualizado para size='lg'."
