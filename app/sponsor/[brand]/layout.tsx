export default function SponsorLayout({ children }:{ children: React.ReactNode }) {
  // Topbar e container já são gerenciados pelo ClientShell.
  return <>{children}</>;
}
