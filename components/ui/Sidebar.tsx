"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { readSession } from "@/components/lib/session";

function Item({href, children, active}:{href:string; children:React.ReactNode; active:boolean}){
  return (
    <Link
      href={href}
      className={`nav-pill ${active ? "nav-pill--active" : ""}`}
    >
      {children}
    </Link>
  );
}

export default function Sidebar(){
  const { role, brand } = readSession();
  const pathname = usePathname();
  const isSponsor = role === "sponsor";

  if (isSponsor){
    const base = `/sponsor/${(brand||"acme").toLowerCase()}`;
    const items = [
      { href: `${base}/overview`,   label: "Overview" },
      { href: `${base}/results`,    label: "Resultados" },
      { href: `${base}/financials`, label: "Financeiro" },
      { href: `${base}/events`,     label: "Eventos" },
      { href: `${base}/assets`,     label: "Assets" },
      { href: `${base}/settings`,   label: "Settings" },
    ];
    return (
      <aside className="space-y-3">
        {items.map(i=>(
          <Item key={i.href} href={i.href} active={pathname.startsWith(i.href)}>{i.label}</Item>
        ))}
      </aside>
    );
  }

  // Admin
  const items = [
    { href: "/",           label: "Overview" },
    { href: "/pipeline",   label: "Pipeline" },
    { href: "/projetos",   label: "Projetos" },
    { href: "/settings",   label: "Settings" },
  ];
  return (
    <aside className="space-y-3">
      {items.map(i=>(
        <Item key={i.href} href={i.href} active={pathname === i.href}>{i.label}</Item>
      ))}
    </aside>
  );
}
