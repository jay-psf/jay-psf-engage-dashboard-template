cd /workspaces/jay-psf-engage-dashboard-template

# 1) Arquivo de fontes do Next
mkdir -p app
cat > app/fonts.ts << 'EOF'
import { Inter, Sora } from "next/font/google";

export const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

export const sora = Sora({
  subsets: ["latin"],
  variable: "--font-sora",
  weight: ["400","500","600","700"],
  display: "swap",
});
EOF
# 2) Atualiza globals.css (mantendo seu @tailwind e tokens)
cat > styles/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* tokens já existem e ficam por último para poderem sobrescrever */
@import "./tokens.css";

/* Variáveis de fonte vindas do app/fonts.ts via className no layout */
:root { --font-inter: Inter, system-ui, sans-serif; --font-sora: Sora, system-ui, sans-serif; }

/* Font stacks */
.body-font { font-family: var(--font-inter), system-ui, -apple-system, Segoe UI, Roboto, Arial, "Apple Color Emoji","Segoe UI Emoji"; }
.display-font { font-family: var(--font-sora), var(--font-inter), system-ui, -apple-system, Segoe UI, Roboto, Arial; }

/* Animação suave de entrada */
@keyframes fadeInUp { from { opacity: .01; transform: translateY(6px) } to { opacity: 1; transform: none } }
.fade-in { animation: fadeInUp .35s ease-out both; }
EOF
# 3) Componente de layout que remove Topbar/Sidebar na rota /login
mkdir -p components
cat > components/LayoutShell.tsx << 'EOF'
"use client";
import { usePathname } from "next/navigation";
import Sidebar from "@/components/ui/Sidebar";
import Topbar from "@/components/ui/Topbar";

export default function LayoutShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const isLogin = pathname === "/login";

  if (isLogin) {
    // Tela de login full-screen, sem chrome
    return (
      <div className="min-h-screen">{children}</div>
    );
  }

  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text)]">
      <Topbar />
      <div className="mx-auto grid max-w-screen-2xl grid-cols-[260px,1fr] gap-6 p-6">
        <Sidebar />
        <main className="min-h-[70vh]">{children}</main>
      </div>
    </div>
  );
}
EOF
# 4) app/layout.tsx passa a usar as fontes e o LayoutShell
cat > app/layout.tsx << 'EOF'
import "../styles/globals.css";
import "../styles/tokens.css";
import type { Metadata } from "next";
import { inter, sora } from "./fonts";
import LayoutShell from "@/components/LayoutShell";

export const metadata: Metadata = {
  title: "Engage Dashboard",
  description: "Patrocínios & Ativações",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR" className={`${inter.variable} ${sora.variable}`}>
      <body className="body-font">
        <LayoutShell>{children}</LayoutShell>
      </body>
    </html>
  );
}
EOF
# 5) Botão arredondado, tamanhos e variantes
mkdir -p components/ui
cat > components/ui/Button.tsx << 'EOF'
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
EOF
# 6) Página /login com layout centralizado e fade-in
cat > app/login/page.tsx << 'EOF'
"use client";
import { useEffect } from "react";
import type { Metadata } from "next";
import LoginForm from "./login-form";

export const metadata: Metadata = {
  title: "Login • Engage",
};

export default function Page() {
  // garante que a tela inicia “limpa”
  useEffect(() => {
    document.documentElement.removeAttribute("data-theme");
  }, []);

  return (
    <main className="min-h-screen grid place-items-center px-4 bg-[var(--bg)]">
      <div className="w-full max-w-4xl fade-in">
        <h1 className="display-font text-2xl font-semibold mb-4">Entrar</h1>
        <LoginForm />
      </div>
    </main>
  );
}
EOF
cat > app/login/login-form.tsx << 'EOF'
"use client";
import { useState, useEffect } from "react";
import Button from "@/components/ui/Button";

type Role = "admin" | "sponsor";

export default function LoginForm() {
  const [role, setRole] = useState<Role>("admin");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  useEffect(() => {
    setUsername("admin");
    setPassword("123456");
  }, []);

  function resolveBrandFromUser(u: string): string {
    return u.toLowerCase() === "sponsor" ? "heineken" : "acme";
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    const ok =
      (role === "admin" && username === "admin" && password === "123456") ||
      (role === "sponsor" && username === "sponsor" && password === "000000");

    if (!ok) { alert("Usuário ou senha inválidos"); return; }

    const brand = role === "sponsor" ? resolveBrandFromUser(username) : undefined;
    const session = { role, brand, username };
    window.localStorage.setItem("session", JSON.stringify(session));

    const html = document.documentElement;
    if (role === "sponsor") html.setAttribute("data-theme", "dark");
    else html.removeAttribute("data-theme");

    if (role === "sponsor") window.location.href = `/sponsor/${brand}/overview`;
    else window.location.href = "/";
  }

  return (
    <div className="space-y-6">
      <div className="grid md:grid-cols-2 gap-4">
        <button
          onClick={() => { setRole("admin"); setUsername("admin"); setPassword("123456"); }}
          className={`rounded-2xl border p-5 text-left bg-card border-border shadow-soft ${role==="admin"?"ring-2 ring-accent":""}`}
        >
          <div className="text-sm text-muted">Perfil</div>
          <div className="mt-1 display-font font-semibold">Interno (Admin)</div>
          <div className="text-sm text-muted mt-1">Acesso completo</div>
        </button>

        <button
          onClick={() => { setRole("sponsor"); setUsername("sponsor"); setPassword("000000"); }}
          className={`rounded-2xl border p-5 text-left bg-card border-border shadow-soft ${role==="sponsor"?"ring-2 ring-accent":""}`}
        >
          <div className="text-sm text-muted">Perfil</div>
          <div className="mt-1 display-font font-semibold">Patrocinador</div>
          <div className="text-sm text-muted mt-1">Acesso ao próprio contrato</div>
        </button>
      </div>

      <form onSubmit={onSubmit} className="rounded-2xl border border-border bg-card p-6 shadow-soft space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <label className="block">
            <div className="text-sm mb-1">Usuário</div>
            <input
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full h-11 rounded-xl border border-border bg-surface px-3"
              placeholder={role === "admin" ? "admin" : "sponsor"}
            />
          </label>
          <label className="block">
            <div className="text-sm mb-1">Senha</div>
            <input
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full h-11 rounded-xl border border-border bg-surface px-3"
              placeholder={role === "admin" ? "123456" : "000000"}
              type="password"
            />
          </label>
        </div>

        <div className="flex gap-3 pt-2">
          <Button type="submit" size="lg" className="px-6">Entrar</Button>
          <Button type="button" variant="outline" onClick={()=>{
            if (role==="admin") { setUsername("admin"); setPassword("123456"); }
            else { setUsername("sponsor"); setPassword("000000"); }
          }}>Preencher exemplo</Button>
        </div>
      </form>
    </div>
  );
}
EOF
corepack enable >/dev/null 2>&1 || true
pnpm install --silent
pnpm build 2>&1 | tee .last_build.log
tail -n 80 .last_build.log

git add -A
git commit -m "patch3(ui): Sora/Inter, login full-screen com fade, botão arredondado, LayoutShell"
git push -u origin main