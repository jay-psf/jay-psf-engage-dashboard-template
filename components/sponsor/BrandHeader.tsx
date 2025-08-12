"use client";

type Props = { brand?: string };

function brandLogo(brand?: string) {
  const b = (brand || "acme").toLowerCase();
  return `/logos/${b}.png`;
}

// Gradiente/cores por marca (fallback roxo)
function brandBackground(brand?: string) {
  const b = (brand || "acme").toLowerCase();
  if (b === "heineken") {
    // verde profundo com vinheta
    return "radial-gradient(1200px 400px at 20% 0%, rgba(0,255,170,0.10), transparent 60%), linear-gradient(160deg, #02160E 0%, #020B07 60%, #010705 100%)";
  }
  // fallback roxo escuro
  return "radial-gradient(1200px 400px at 20% 0%, rgba(126,58,242,0.20), transparent 60%), linear-gradient(160deg, #0E0A18 0%, #0A0811 60%, #090711 100%)";
}

export default function BrandHeader({ brand }: Props) {
  const bg = brandBackground(brand);
  const logo = brandLogo(brand);

  return (
    <section
      className="relative overflow-hidden rounded-2xl border border-border mb-6 md:mb-8"
      style={{ background: bg }}
    >
      <div className="flex items-center justify-center p-10 md:p-16">
        <img
          src={logo}
          alt={brand ?? "brand"}
          width={220}
          height={220}
          style={{ display: "block", borderRadius: 12, filter: "drop-shadow(0 18px 60px rgba(0,0,0,.45))" }}
        />
      </div>
      {/* vinheta sutil para profundidade */}
      <div className="pointer-events-none absolute inset-0"
           style={{ boxShadow: "inset 0 0 0 1px rgba(255,255,255,0.04)" }} />
    </section>
  );
}
