set -euo pipefail
echo "== Patch 30: Login deslizante + Glow gradiente + Topbar unificado =="

# 1) Tokens: utilitário de glow com degradê radial
# (apenas ANEXA se ainda não existir)
if ! grep -q '/* === glow iris' styles/tokens.css 2>/dev/null; then
cat >> styles/tokens.css <<'CSS'

/* === glow iris (gradiente radial) === */
.glow-iris{
  position: relative;
  isolation: isolate;
  transition: transform .18s ease, box-shadow .18s ease;
}
.glow-iris::before{
  content:"";
  position:absolute; inset:-12px;
  border-radius:inherit; pointer-events:none; z-index:-1;
  background:
    radial-gradient(120px 120px at 30% 30%, rgba(126,58,242,.20), transparent 60%),
    radial-gradient(140px 140px at 70% 70%, rgba(108,43,217,.18), transparent 65%);
  filter: blur(10px);
  opacity: .0;
  transition: opacity .20s ease;
}
.glow-iris:hover::before, .glow-iris:focus-visible::before{ opacity: 1; }
.glow-iris:hover{ transform: translateY(-1px); }
CSS
fi

# 2) ToggleTabs: controle segmentado para o login
mkdir -p components/ui
cat > components/ui/ToggleTabs.tsx <<'TSX'
"use client";
import * as React from "react";

type Opt = { value: string; label: string };
type Props = {
  value: string;
  onChange: (v: string) => void;
  options: Opt[];
};

export default function ToggleTabs({ value, onChange, options }: Props) {
  return (
    <div className="relative grid grid-cols-2 rounded-full border border-[var(--borderC)] bg-[var(--surface)] p-1">
      {options.map((o) => {
        const active = o.value === value;
        return (
          <button
            key={o.value}
            type="button"
            onClick={() => onChange(o.value)}
            className={`rounded-full px-4 py-1.5 text-sm transition glow-iris ${
              active ? "bg-[var(--accent)] text-white" : "bg-[var(--card)]"
            }`}
            aria-pressed={active}
          >
            {o.label}
          </button>
        );
      })}
    </div>
  );
}
TSX

# 3) LoginForm refeito com o toggle deslizante
cat > app/login/login-form.tsx <<'TSX'
"use client";
import * as React from "react";
import ToggleTabs from "@/components/ui/ToggleTabs";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const [role, setRole] = React.useState<Role>("admin");
  const [username, setUsername] = React.useState("");
  const [password, setPassword] = React.useState("");
  const [loading, setLoading] = React.useState(false);

  React.useEffect(() => {
    // pré-preenche p/ teste rápido
    setUsername("admin");
    setPassword("123456");
  }, []);

  function resolveBrandFromUser(u: string) {
    return u.toLowerCase() === "sponsor" ? "heineken" : "acme";
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    const ok =
      (role === "admin" && username === "admin" && password === "123456") ||
      (role === "sponsor" && username === "sponsor" && password === "000000");
    if (!ok) return alert("Usuário ou senha inválidos");

    setLoading(true);
    const brand = role === "sponsor" ? resolveBrandFromUser(username) : undefined;
    const resp = await fetch("/api/auth", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ role, brand }),
    }).catch(()=>null);
    setLoading(false);
    if (!resp || !resp.ok) return alert("Falha ao autenticar");

    if (role === "sponsor") window.location.href = `/sponsor/${brand}/overview`;
    else window.location.href = "/";
  }

  return (
    <div className="mx-auto w-full max-w-md rounded-2xl border border-[var(--borderC)] bg-[var(--card)] p-6 shadow-soft"
         data-animate="in">
      <div className="mb-5 text-center">
        <h1 className="text-xl font-semibold">Entrar</h1>
        <p className="text-sm text-[var(--muted)] mt-1">
          Escolha o perfil e informe suas credenciais.
        </p>
      </div>

      <div className="flex justify-center mb-5">
        <ToggleTabs
          value={role}
          onChange={(v)=> {
            const r = (v as Role);
            setRole(r);
            if (r === "admin"){ setUsername("admin"); setPassword("123456"); }
            else { setUsername("sponsor"); setPassword("000000"); }
          }}
          options={[
            { value: "admin", label: "Interno" },
            { value: "sponsor", label: "Patrocinador" },
          ]}
        />
      </div>

      <form onSubmit={onSubmit} className="space-y-4">
        <label className="block">
          <div className="text-sm mb-1">Usuário</div>
          <input
            value={username}
            onChange={(e)=>setUsername(e.target.value)}
            className="input rounded-xl bg-[var(--surface)] border border-[var(--borderC)] px-3"
            placeholder={role === "admin" ? "admin" : "sponsor"}
          />
        </label>
        <label className="block">
          <div className="text-sm mb-1">Senha</div>
          <input
            type="password"
            value={password}
            onChange={(e)=>setPassword(e.target.value)}
            className="input rounded-xl bg-[var(--surface)] border border-[var(--borderC)] px-3"
            placeholder={role === "admin" ? "123456" : "000000"}
          />
        </label>

        <div className="flex gap-2 pt-2">
          <button type="submit"
                  className="glow-iris rounded-full bg-[var(--accent)] px-4 py-2 text-sm text-white">
            {loading ? "Entrando..." : "Entrar"}
          </button>
          <button type="button"
                  onClick={()=>{
                    if (role==="admin"){ setUsername("admin"); setPassword("123456"); }
                    else { setUsername("sponsor"); setPassword("000000"); }
                  }}
                  className="glow-iris rounded-full border border-[var(--borderC)] bg-[var(--card)] px-4 py-2 text-sm">
            Preencher exemplo
          </button>
        </div>
      </form>
    </div>
  );
}
TSX

# 4) Página de login (server component com metadata; sem "use client")
cat > app/login/page.tsx <<'TSX'
import type { Metadata } from "next";
import LoginForm from "./login-form";

export const metadata: Metadata = { title: "Login • Engage" };

export default function Page() {
  return (
    <main className="min-h-[calc(100vh-64px)] grid place-items-center px-4">
      <div className="w-full max-w-4xl">
        <h1 className="sr-only">Entrar</h1>
        <LoginForm />
      </div>
    </main>
  );
}
TSX

# 5) Topbar unificado e logout robusto (regrava sem alterar tipos)
cat > components/ui/Topbar.tsx <<'TSX'
"use client";
/* eslint-disable @next/next/no-img-element */
import * as React from "react";
import { usePathname } from "next/navigation";

function readCookie(name: string): string | undefined {
  if (typeof document === "undefined") return;
  const re = new RegExp("(?:^|; )" + name.replace(/([.$?*|{}()[\\]\\/+^])/g,"\\$1") + "=([^;]*)");
  const m = document.cookie.match(re);
  return m ? decodeURIComponent(m[1]) : undefined;
}

export default function Topbar() {
  const pathname = usePathname();
  const role = readCookie("role");
  const brand = readCookie("brand") || "heineken";

  const isSponsor = role === "sponsor";
  const sBase = `/sponsor/${brand}`;
  const adminNav = [
    { href: "/",            label: "Overview",   active: pathname === "/" },
    { href: "/projetos",    label: "Projetos",   active: pathname.startsWith("/projetos") },
    { href: "/pipeline",    label: "Pipeline",   active: pathname.startsWith("/pipeline") },
    { href: "/settings",    label: "Settings",   active: pathname.startsWith("/settings") },
  ];
  const sponsorNav = [
    { href: `${sBase}/overview`,   label: "Overview",   active: pathname.startsWith(`${sBase}/overview`) },
    { href: `${sBase}/results`,    label: "Resultados", active: pathname.startsWith(`${sBase}/results`) },
    { href: `${sBase}/financials`, label: "Financeiro", active: pathname.startsWith(`${sBase}/financials`) },
    { href: `${sBase}/events`,     label: "Eventos",    active: pathname.startsWith(`${sBase}/events`) },
    { href: `${sBase}/assets`,     label: "Assets",     active: pathname.startsWith(`${sBase}/assets`) },
    { href: `${sBase}/settings`,   label: "Settings",   active: pathname.startsWith(`${sBase}/settings`) },
  ];
  const nav = isSponsor ? sponsorNav : adminNav;

  const onLogout = async () => {
    try {
      await fetch("/api/logout", { method: "POST" });
    } finally {
      // limpa cookies client-side por garantia
      document.cookie = "role=; Max-Age=0; path=/";
      document.cookie = "brand=; Max-Age=0; path=/";
      window.location.href = "/login";
    }
  };

  const brandLogo = isSponsor ? (()=>{
    // tenta localStorage (custom logo), senão /public/logos/<brand>.png
    try {
      const k = `brandLogo:${String(brand).toLowerCase()}`;
      const v = window.localStorage.getItem(k);
      if (v) return v;
    } catch {}
    return `/logos/${String(brand).toLowerCase()}.png`;
  })() : null;

  return (
    <header className="sticky top-0 z-30 border-b border-[var(--borderC)] bg-[var(--card)]/85 backdrop-blur">
      <div className="mx-auto flex h-16 max-w-screen-2xl items-center justify-between px-4">
        <div className="flex items-center gap-3">
          <span className="text-base font-semibold">Engage</span>

          {/* Menu superior unificado */}
          <nav className="ml-2 hidden gap-1 md:flex">
            {nav.map(item => (
              <a
                key={item.href}
                href={item.href}
                className={`rounded-full px-3 py-1.5 text-sm transition glow-iris ${
                  item.active ? "bg-[var(--accent)] text-white" : "border border-[var(--borderC)] bg-[var(--card)]"
                }`}
              >
                {item.label}
              </a>
            ))}
          </nav>
        </div>

        <div className="flex items-center gap-3">
          {isSponsor && (
            <div className="rounded-full border border-[var(--borderC)] bg-[var(--card)] px-2 py-1">
              <img
                src={brandLogo || ""}
                alt={brand || "brand"}
                width={40}
                height={40}
                style={{ display:"block", borderRadius:12, objectFit:"cover" }}
              />
            </div>
          )}
          <button onClick={onLogout} className="glow-iris rounded-full border border-[var(--borderC)] bg-[var(--card)] px-3 py-1.5 text-sm">
            Sair
          </button>
        </div>
      </div>
    </header>
  );
}
TSX

echo "== Build =="
pnpm -s build
