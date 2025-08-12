"use client";
import { useEffect } from "react";
import { useForm } from "react-hook-form";
import Button from "@/components/ui/Button";

type FormData = {
  companyName: string;
  cnpj: string;
  email: string;
  phone: string;
};

export default function SettingsPage(){
  const { register, handleSubmit, reset } = useForm<FormData>({
    defaultValues: { companyName:"", cnpj:"", email:"", phone:"" }
  });

  useEffect(()=>{
    try{
      const raw = localStorage.getItem("settings");
      if(raw) reset(JSON.parse(raw));
    }catch{}
  },[reset]);

  function onSubmit(data:FormData){
    localStorage.setItem("settings", JSON.stringify(data));
    alert("Dados salvos!");
  }

  return (
    <section className="rounded-2xl border bg-card p-6 shadow-soft">
      <h1 className="text-xl font-semibold mb-4">Settings</h1>
      <form onSubmit={handleSubmit(onSubmit)} className="grid gap-4 md:grid-cols-2">
        <label className="block">
          <div className="text-sm mb-1">Nome da empresa</div>
          <input className="input" {...register("companyName")} placeholder="Entourage" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">CNPJ</div>
          <input className="input" {...register("cnpj")} placeholder="00.000.000/0001-00" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">E-mail</div>
          <input className="input" type="email" {...register("email")} placeholder="contato@empresa.com" />
        </label>
        <label className="block">
          <div className="text-sm mb-1">Telefone</div>
          <input className="input" {...register("phone")} placeholder="(11) 99999-9999" />
        </label>
        <div className="md:col-span-2 pt-2">
          <Button type="submit" size="lg">Salvar</Button>
        </div>
      </form>
    </section>
  );
}
