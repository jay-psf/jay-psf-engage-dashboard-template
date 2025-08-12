set -euo pipefail
echo "== Patch 40: Topbar unificado (glass) + Image otimizado =="

mkdir -p components/ui

# 1) Topbar client com glass, next/image e menus por papel
cat > components/ui/Topbar.tsx <<'TSX'
"use client";

import Link from "next/link";
import Image from "next/image";
import { usePathname, useRouter } from "next/navigation";
import { readSession } from "@/components/lib/session";

const navAdmin = [
  { href: "/admin", label: "Overview" },
  { href: "/pipeline", label: "Pipeline" },
  { href: "/projetos", label: "Projetos" },
  { href: "/settings", label: "Settings" },
];

function sponsorNav(brand: string){
  const base = `/sponsor/${brand}`;
  return [
    { href: `${base}/overview`, label: "Overview" },
    { href: `${base}/results`, label: "Resultados" },
    { href: `${base}/financials`, label: "Financeiro" },
    { href: `${base}/events`, label: "Eventos" },
    { href: `${base}/assets`, label: "Assets" },
    { href: `${base}/settings`, label: "Settings" },
  ];
}

export default function Topbar(){
  const pathname = usePathname();
  const router = useRouter();
  const { role, brand } = readSession();

  const isSponsor = role === "sponsor" && brand;
  const items = isSponsor ? sponsorNav(String(brand)) : navAdmin;

  async function logout(){
    try {
      await fetch("/api/logout", { method:"POST" });
    } finally {
      router.push("/login");
    }
  }

  return (
    <header className="glass sticky top-0 z-40">
      <div className="container" style={{display:"flex",alignItems:"center",gap:16,height:64}}>
        {/* Logo Engage (clique -> home) */}
        <Link href="/" aria-label="Ir para Home" className="focus-ring" style={{display:"flex",alignItems:"center",gap:10}}>
          <Image src="/engage-logo.svg" alt="Engage" width={28} height={28} priority />
          <span className="h3" style={{fontSize:"18px"}}>Engage</span>
        </Link>

        {/* Nav */}
        <nav style={{display:"flex",gap:8,marginLeft:16,flex:1,alignItems:"center"}}>
          {items.map(item=>{
            const active = pathname.startsWith(item.href);
            return (
              <Link key={item.href} href={item.href}
                className={"focus-ring"}
                style={{
                  padding:"8px 12px",
                  borderRadius:12,
                  border: active ? "1px solid var(--borderC)" : "1px solid transparent",
                  background: active ? "var(--surface)" : "transparent",
                  fontSize:"14px"
                }}>
                {item.label}
              </Link>
            );
          })}
        </nav>

        {/* Logo do sponsor (se houver) -> perfil overview */}
        {isSponsor && (
          <Link href={`/sponsor/${brand}/overview`} aria-label="Perfil do patrocinador"
                className="focus-ring" style={{display:"flex",alignItems:"center"}}>
            <div style={{
              width:48,height:48, borderRadius:12, overflow:"hidden",
              border:"1px solid var(--borderC)", background:"var(--card)"
            }}>
              <Image src={`/logos/${String(brand).toLowerCase()}.png`} alt={String(brand)}
                     width={96} height={96} style={{width:"100%",height:"100%",objectFit:"contain"}} />
            </div>
          </Link>
        )}

        {/* Sair */}
        <button onClick={logout} className="focus-ring"
                style={{marginLeft:12,padding:"10px 14px",borderRadius:12,border:"1px solid var(--borderC)",background:"var(--card)"}}>
          Sair
        </button>
      </div>
    </header>
  );
}
TSX

# 2) Garante que o app use o Topbar (sem duplicidades) e tenha respiro sob o header
if [ -f components/ClientShell.tsx ]; then
  cp components/ClientShell.tsx components/ClientShell.tsx.bak40 || true
  # Remove qualquer topbar antigo e injeta o novo
  awk '
  BEGIN{t=0}
  /<Topbar/ {t=1}
  { if(t==0) print }
  END{}
  ' components/ClientShell.tsx > components/ClientShell.tmp || true
  mv components/ClientShell.tmp components/ClientShell.tsx

  # Reinsere Topbar único no topo do ClientShell
  if ! grep -q "import Topbar from \"@/components/ui/Topbar\"" components/ClientShell.tsx; then
    sed -i '1i "use client";\nimport Topbar from "@/components/ui/Topbar";' components/ClientShell.tsx
  fi
  if ! grep -q "<Topbar />" components/ClientShell.tsx; then
    sed -i 's#return (#[[RETURN]]#' components/ClientShell.tsx
    sed -i 's#[[RETURN]]#return (<><Topbar />#' components/ClientShell.tsx
    sed -i 's#</main>#</main></>#' components/ClientShell.tsx
  fi
fi

echo "== Build =="
pnpm build
