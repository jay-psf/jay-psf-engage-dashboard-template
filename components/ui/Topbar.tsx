'use client';
import { useEffect, useState } from 'react';

export function Topbar(){
  const [dark, setDark] = useState(false);
  useEffect(()=>{
    const stored = typeof window !== 'undefined' ? localStorage.getItem('theme') : null;
    const isDark = stored ? stored==='dark' : (typeof window !== 'undefined' && window.matchMedia('(prefers-color-scheme: dark)').matches);
    setDark(!!isDark);
    if (typeof document !== 'undefined') {
      document.documentElement.classList.toggle('dark', !!isDark);
    }
  },[]);
  const toggle = ()=>{
    const next = !dark;
    setDark(next);
    if (typeof document !== 'undefined') {
      document.documentElement.classList.toggle('dark', next);
    }
    if (typeof window !== 'undefined') {
      localStorage.setItem('theme', next ? 'dark' : 'light');
    }
  };

  return (
    <header className="topbar">
      <div className="mx-auto max-w-7xl px-4 h-14 flex items-center justify-between">
        <div className="font-semibold">Dashboard Engage</div>
        <div className="flex items-center gap-2">
          <button className="btn" onClick={toggle}>{dark ? '🌙 Dark' : '☀️ Light'}</button>
        </div>
      </div>
    </header>
  );
}
