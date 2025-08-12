"use client";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { readSession } from "@/components/lib/session";

export default function Topbar(){
  const { role, brand } = readSession();
  const pathname = usePathname();

  const onLogout = async ()=>{
    try{
      await fetch("/api/logout", { method:"POST" });
    }catch{}
    window.location.href = "/login";
  };

  // Logo só quando sponsor
  const showBrand = role === "sponsor" && brand;

  return (
    <header className="sticky top-0 z-30 bg-[var(--bg)]/85 backdrop-blur border-b border-border">
      <div className="mx-auto max-w-screen-2xl flex items-center justify-between gap-3 px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-[var(--card)] grid place-items-center border border-border">
            <span className="text-sm font-semibold">E</span>
          </div>
          <span className="font-semibold">Engage</span>
        </div>

        <div className="flex items-center gap-2">
          {showBrand && (
            <span className="inline-flex items-center h-10 rounded-full border border-border bg-[var(--card)] px-3">
              <Image
                alt={brand!}
                src={`/logos/${brand!.toLowerCase()}.png`}
                width={48} height={48}
                style={{borderRadius:8, display:"block"}}
              />
            </span>
          )}
          <button onClick={onLogout} className="btn btn-outline">Sair</button>
        </div>
      </div>
    </header>
  );
}
