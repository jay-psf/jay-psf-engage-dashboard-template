import Link from "next/link";

export default function Sidebar() {
  const item = (href: string, label: string) => (
    <Link
      href={href}
      className="block px-3 py-2 rounded-lg hover:bg-neutral-200 transition"
    >
      {label}
    </Link>
  );

  return (
    <aside className="w-64 shrink-0 border-r bg-white p-4 space-y-2">
      <h2 className="font-semibold mb-2">Menu</h2>
      {item("/", "Dashboard")}
      {item("/pipeline", "Pipeline")}
      {item("/projetos", "Projetos")}
      {item("/admin", "Admin")}
    </aside>
  );
}
