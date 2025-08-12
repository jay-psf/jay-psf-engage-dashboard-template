"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
const items = [
  { href: "/", label: "Dashboard" },
  { href: "/pipeline", label: "Pipeline" },
  { href: "/projetos", label: "Projetos" },
];
export default function Sidebar() {
  const pathname = usePathname();
  return (
    <aside className="w-56 shrink-0 border-r bg-white">
      <div className="p-4 font-semibold">Engage</div>
      <nav className="flex flex-col gap-1 p-2">
        {items.map((i) => {
          const active = pathname === i.href;
          return (
            <Link
              key={i.href}
              href={i.href}
              className={`px-3 py-2 rounded hover:bg-neutral-100 ${
                active ? "bg-neutral-100 font-medium" : ""
              }`}
            >
              {i.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
