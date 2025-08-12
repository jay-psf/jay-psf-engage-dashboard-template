set -euo pipefail

echo "== Patch 22: Sponsor sem menu duplicado + logo 2x + glow forte =="

# 1) Tokens: adiciona ring forte para o glow
apply_tokens() {
cat > styles/tokens.css <<'CSS'
:root{
  --accent:#7E3AF2; --accent-600:#6C2BD9; --accent-700:#5B21B6;
  --ring: rgba(126,58,242,.35);
  --ring-strong: rgba(126,58,242,.60);

  /* Light */
  --bg:#F6F8FB; --card:#FFFFFF; --surface:#F2F4F9;
  --text:#0B1524; --muted:#667085; --borderC:rgba(16,24,40,.12);
  --radius:16px; --radius-lg:20px; --elev:0 10px 30px rgba(2,32,71,.08);
}
/* Dark (sponsor por padrão) */
:root[data-theme="dark"]{
  --bg:#0B1220; --card:#0F1627; --surface:#0C1322;
  --text:#E6E8EC; --muted:#9BA3AF; --borderC:rgba(255,255,255,.12);
  --elev:0 18px 40px rgba(0,0,0,.45);
}

html,body{background:var(--bg);color:var(--text);}
.bg-card{background:var(--card);} .bg-surface{background:var(--surface);}
.text-muted{color:var(--muted);} .border{border:1px solid var(--borderC);}
.border-border{border-color:var(--borderC);} .rounded-xl{border-radius:var(--radius);}
.rounded-2xl{border-radius:var(--radius-lg);} .shadow-soft{box-shadow:var(--elev);}

/* Botões genéricos */
.btn{height:40px; padding:0 14px; border-radius:999px; border:1px solid var(--borderC);
background:var(--card); transition:transform .15s ease, box-shadow .2s ease, background .15s ease;}
.btn:hover{transform:translateY(-1px) scale(1.02);
  box-shadow:
    0 0 0 2px rgba(255,255,255,.02),
    0 0 0 10px var(--ring-strong),
    0 18px 40px rgba(0,0,0,.25);
}
.btn-primary{background:var(--accent); color:#fff; border-color:transparent;}
.btn-primary:hover{box-shadow:
    0 0 0 10px var(--ring-strong),
    0 18px 48px rgba(126,58,242,.45);
  transform:translateY(-1px) scale(1.03);
}
.btn-outline{background:var(--card);}
CSS
}
apply_tokens

# 2) Topbar: logo do sponsor ~2x maior e sem corte + glow mais forte nos links
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { readSession } from "@/components/lib/session";

function NavLink({ href, active, children }:{
  href:string; active:boolean; children:React.ReactNode;
}) {
  return (
    <Link
      href={href}
      className={[
        "h-9 px-3 rounded-full border transition inline-flex items-center",
        active
          ? "bg-[var(--accent)] text-white border-transparent"
          : "bg-[var(--card)] text-[var(--text)] border-border hover:shadow-[0_0_0_12px_var(--ring-strong)] hover:-translate-y-[1px] hover:scale-[1.02]"
      ].join(" ")}
    >
      {children}
    </Link>
  );
}

export default function Topbar(){
  const { role, brand } = readSession();
  const pathname = usePathname();
  const isSponsor = role === "sponsor";
  const brandSlug = (brand || "acme").toLowerCase();

  const adminNav = [
    { href: "/", label: "Overview", active: pathname === "/" },
    { href: "/pipeline", label: "Pipeline", active: pathname === "/pipeline" },
    { href: "/projetos", label: "Projetos", active: pathname === "/projetos" },
    { href: "/settings", label: "Settings", active: pathname === "/settings" },
  ];

  const sBase = `/sponsor/${brandSlug}`;
  const sponsorNav = [
    { href: `${sBase}/overview`,   label: "Overview",   active: pathname.startsWith(`${sBase}/overview`) },
    { href: `${sBase}/results`,    label: "Resultados", active: pathname.startsWith(`${sBase}/results`) },
    { href: `${sBase}/financials`, label: "Financeiro", active: pathname.startsWith(`${sBase}/financials`) },
    { href: `${sBase}/events`,     label: "Eventos",    active: pathname.startsWith(`${sBase}/events`) },
    { href: `${sBase}/assets`,     label: "Assets",     active: pathname.startsWith(`${sBase}/assets`) },
    { href: `${sBase}/settings`,   label: "Settings",   active: pathname.startsWith(`${sBase}/settings`) },
  ];

  const onLogout = async () => { try { await fetch("/api/logout", { method:"POST" }); } finally { window.location.href="/login"; } };

  return (
    <header className="sticky top-0 z-30 bg-[var(--bg)]/85 backdrop-blur border-b border-border">
      <div className="mx-auto max-w-screen-2xl flex items-center justify-between gap-3 px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-[var(--card)] grid place-items-center border border-border">
            <span className="text-sm font-semibold">E</span>
          </div>
          <span className="font-semibold">Engage</span>
        </div>

        <nav className="hidden md:flex items-center gap-2">
          {(isSponsor ? sponsorNav : adminNav).map((i)=>(
            <NavLink key={i.href} href={i.href} active={i.active}>{i.label}</NavLink>
          ))}
        </nav>

        <div className="flex items-center gap-3">
          {isSponsor && brand && (
            <span className="inline-flex items-center h-12 rounded-xl border border-border bg-[var(--card)] px-3">
              <Image
                alt={brand}
                src={`/logos/${brandSlug}.png`}
                width={100} height={40}               {/* ≈ 2x e aspecto retangular */}
                style={{ display:"block", objectFit:"contain", borderRadius:10 }}
                priority
              />
            </span>
          )}
          <button onClick={onLogout} className="btn btn-outline">Sair</button>
        </div>
      </div>

      <div className="md:hidden border-t border-border px-4 py-2 flex flex-wrap gap-6">
        {(isSponsor ? sponsorNav : adminNav).map((i)=>(
          <Link key={i.href} href={i.href}
            className={["text-sm", i.active ? "text-[var(--accent)] font-semibold":"opacity-80 hover:opacity-100"].join(" ")}
          >{i.label}</Link>
        ))}
      </div>
    </header>
  );
}
TSX

# 3) ClientShell mantém top‑nav + container (já sem sidebar)

cat > components/ClientShell.tsx <<'TSX'
"use client";
import { usePathname } from "next/navigation";
import Topbar from "@/components/ui/Topbar";
import { readSession } from "@/components/lib/session";

export default function ClientShell({ children }:{children:React.ReactNode}){
  const pathname = usePathname();
  const isLogin = pathname === "/login";
  const { role } = readSession();

  if (typeof window !== "undefined") {
    const pref = localStorage.getItem("theme-pref");
    const html = document.documentElement;
    if (pref === "light" || pref === "dark") html.setAttribute("data-theme", pref);
    else {
      const sys = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark":"light";
      html.setAttribute("data-theme", role === "sponsor" ? "dark" : sys);
    }
  }

  if (isLogin) return <>{children}</>;
  return (
    <>
      <Topbar/>
      <div className="mx-auto max-w-screen-2xl px-4 py-6">
        <main className="min-h-[70vh]">{children}</main>
      </div>
    </>
  );
}
TSX

# 4) Sponsor layout: remove barras/tabs/side duplicadas
mkdir -p app/sponsor/[brand]
cat > app/sponsor/[brand]/layout.tsx <<'TSX'
export default function SponsorLayout({ children }:{ children: React.ReactNode }) {
  // Topbar e container já são gerenciados pelo ClientShell.
  return <>{children}</>;
}
TSX

# 5) (Opcional) limpa qualquer Sidebar residual
cat > components/ui/Sidebar.tsx <<'TSX'
export default function Sidebar(){ return null; }
TSX

# 6) Build
echo "== Build =="
pnpm build
echo "✅ Patch 22 aplicado."
