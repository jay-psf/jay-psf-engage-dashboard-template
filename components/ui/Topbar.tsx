"use client";
import Image from "next/image";
import { useEffect, useState } from "react";
import Button from "./Button";

type Session = { role: "admin" | "sponsor"; brand?: string; username?: string };

function readSession(): Session {
  try { const raw = window.localStorage.getItem("session"); return raw ? JSON.parse(raw) : { role: "admin" }; }
  catch { return { role: "admin" }; }
}

export default function Topbar() {
  const [s, setS] = useState<Session>({ role: "admin" });
  useEffect(() => setS(readSession()), []);
  const isSponsor = s.role === "sponsor";
  const brand = (s.brand || "acme").toLowerCase();
  const logoSrc = brand === "heineken" ? "/logos/heineken.png" : "/logos/acme.svg";

  return (
    <header className="w-full sticky top-0 z-40 backdrop-blur supports-[backdrop-filter]:bg-surface/70 bg-surface border-b border-border">
      <div className="max-w-7xl mx-auto px-4 h-16 flex items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="w-3 h-3 rounded-full bg-accent" />
          <span className="font-semibold">Engage Dashboard</span>
        </div>

        <div className="ml-auto flex items-center gap-4">
          {isSponsor && (
            <div className="relative w-[150px] h-8">
              <Image alt={`${brand} logo`} src={logoSrc} fill className="object-contain" priority />
            </div>
          )}
          <form action="/api/logout" method="post">
            <Button type="submit" variant="outline" size="sm">Sair</Button>
          </form>
        </div>
      </div>
    </header>
  );
}
