"use client";
import Image from "next/image";

type Props = {
  brand?: string;
  username?: string;
  onClick?: () => void;
};

export default function BrandPill({ brand, username, onClick }: Props) {
  // Exibe: [logo] heineken  |  [perfil] Admin
  const text = brand ? brand.toLowerCase() : (username ?? "Perfil");
  const logoSrc = brand ? `/logos/${brand.toLowerCase()}.png` : undefined;

  return (
    <button className="brand-pill" onClick={onClick} aria-label="Perfil">
      {logoSrc ? (
        <Image src={logoSrc} alt={text} width={22} height={22} className="logo" />
      ) : (
        <span className="logo" aria-hidden />
      )}
      <span style={{ textTransform: "capitalize" }}>{text}</span>
    </button>
  );
}
