set -euo pipefail

echo "== Patch 17: Brand Hero + Topbar logo maior e sem texto =="

# 1) Componente BrandHeader (sponsor)
mkdir -p components/sponsor
cat > components/sponsor/BrandHeader.tsx <<'TSX'
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
TSX

# 2) Injeta o BrandHeader no sponsor/[brand]/overview
#    - adiciona import (se ainda não existir)
#    - insere <BrandHeader brand={params.brand} /> logo após o <main> ou no topo do conteúdo
FILE_OVERVIEW="app/sponsor/[brand]/overview/page.tsx"
if [ -f "$FILE_OVERVIEW" ]; then
  # Import
  if ! grep -q 'BrandHeader' "$FILE_OVERVIEW"; then
    sed -i '1s;^;import BrandHeader from "@/components/sponsor/BrandHeader";\n;' "$FILE_OVERVIEW"
  fi

  # Inserção do componente após a primeira ocorrência de "<main" ou dentro do retorno
  if grep -q "<main" "$FILE_OVERVIEW"; then
    # após a tag <main ...>
    sed -i '0,/<main[^>]*>/s//&\n      <BrandHeader brand={params?.brand} \/>/' "$FILE_OVERVIEW" || true
  else
    # fallback: tenta inserir logo após "return ("
    sed -i '0,/return *( *\()/s//return (\n    <>\n      <BrandHeader brand={params?.brand} \/>\n/' "$FILE_OVERVIEW" || true
    # fecha o fragment se abrimos um
    if ! grep -q '</>' "$FILE_OVERVIEW"; then
      sed -i '$s;$; \n    <\/>\n  );;' "$FILE_OVERVIEW" || true
    fi
  fi
fi

# 3) Topbar: só o logo do patrocinador, maior (~48–50px) e sem texto
FILE_TOPBAR="components/ui/Topbar.tsx"
if [ -f "$FILE_TOPBAR" ]; then
  # Garante style como objeto React (evita o erro de string no style)
  sed -i 's/style="border-radius:6px; display:block"/style={{ borderRadius: 8, display: "block" }}/g' "$FILE_TOPBAR" || true
  sed -i 's/style="border-radius:6px; display:block;"/style={{ borderRadius: 8, display: "block" }}/g' "$FILE_TOPBAR" || true

  # Aumenta logo: 20 -> 48
  sed -i 's/width="20"/width="48"/g' "$FILE_TOPBAR" || true
  sed -i 's/height="20"/height="48"/g' "$FILE_TOPBAR" || true
  sed -i 's/width={20}/width={48}/g' "$FILE_TOPBAR" || true
  sed -i 's/height={20}/height={48}/g' "$FILE_TOPBAR" || true

  # Remove o span com o nome da brand (apenas o logo)
  sed -i '/<span className="text-sm[^>]*>{brand}<\/span>/d' "$FILE_TOPBAR" || true
  sed -i '/<span className="text-sm[^>]*>{brand ?? .*}<\/span>/d' "$FILE_TOPBAR" || true
fi

echo "== Build =="
pnpm build

echo "== Patch 17 aplicado! =="
echo "• Overview do patrocinador agora abre com header de marca (logo grande)."
echo "• Topbar mostra só o logo do patrocinador, ~48px."
