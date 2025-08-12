import Image from "next/image";
import Link from "next/link";
import { cookies } from "next/headers";

export default function Topbar() {
  const c = cookies();
  const role = c.get("role")?.value || "guest";
  const brand = c.get("brand")?.value || "";
  const brandName = brand ? brand.charAt(0).toUpperCase() + brand.slice(1) : "";

  return (
    <header className="sticky top-0 z-20 border-b border-entourage-line-light/70 bg-entourage-surface-light/90 backdrop-blur dark:bg-entourage-surface-dark/60 dark:border-entourage-line-dark/70">
      <div className="mx-auto max-w-7xl px-4 py-3 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="h-7 w-7 rounded-md bg-entourage-primary/90" />
          <span className="font-semibold">Engage Dashboard</span>
        </div>

        <div className="flex items-center gap-3">
          {role === "sponsor" && (
            <div className="flex items-center gap-3">
              {/* Se existir o arquivo em /public/brands/<brand>.png ele aparece; senão, mostra só o nome */}
              <div className="relative h-8 w-28">
                <Image
                  src={`/brands/${brand}.png`}
                  alt={brandName || "Marca"}
                  fill
                  className="object-contain"
                  sizes="112px"
                  onError={() => {}}
                />
              </div>
              <span className="text-sm opacity-80">{brandName}</span>
            </div>
          )}

          <Link
            href="/api/logout"
            className="rounded-pill bg-transparent border px-3 py-1.5 text-sm border-entourage-line-light hover:bg-entourage-line-light/40 transition dark:border-entourage-line-dark dark:hover:bg-entourage-line-dark/40"
          >
            Sair
          </Link>
        </div>
      </div>
    </header>
  );
}
