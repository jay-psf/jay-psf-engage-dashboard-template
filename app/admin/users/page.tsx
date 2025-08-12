"use client";
import { useState } from "react";

type Role = "admin" | "sponsor";
type U = { id: string; name: string; email: string; role: Role };

export default function AdminUsers(){
  const [list, setList] = useState<U[]>([
    { id:"1", name:"Admin Demo", email:"admin@engage.com", role:"admin" },
    { id:"2", name:"Sponsor Demo", email:"contact@heineken.com", role:"sponsor" },
  ]);
  const [name,setName]=useState(""); const [email,setEmail]=useState(""); const [role,setRole]=useState<Role>("sponsor");

  function addUser(e:React.FormEvent){ e.preventDefault();
    const id = String(Date.now());
    setList(prev=>[...prev,{ id, name, email, role }]);
    setName(""); setEmail(""); setRole("sponsor");
  }
  function remove(id:string){ setList(prev=>prev.filter(x=>x.id!==id)); }

  return (
    <div className="container py-6">
      <h1 className="text-2xl font-semibold mb-4">Usuários</h1>
      <form onSubmit={addUser} className="bg-card rounded-2xl border border-border p-4 shadow-soft grid md:grid-cols-4 gap-3 mb-6">
        <input className="input" placeholder="Nome" value={name} onChange={e=>setName(e.target.value)} />
        <input className="input" placeholder="E-mail" value={email} onChange={e=>setEmail(e.target.value)} />
        <select className="input" value={role} onChange={e=>setRole(e.target.value as Role)}>
          <option value="sponsor">Patrocinador</option>
          <option value="admin">Admin</option>
        </select>
        <button className="btn btn-primary">Adicionar</button>
      </form>

      <div className="bg-card rounded-2xl border border-border shadow-soft overflow-hidden">
        <table className="w-full text-sm">
          <thead className="text-muted">
            <tr><th className="text-left p-3">Nome</th><th className="text-left p-3">E-mail</th><th className="text-left p-3">Papel</th><th className="p-3"></th></tr>
          </thead>
          <tbody>
            {list.map(u=>(
              <tr key={u.id} className="border-t border-border">
                <td className="p-3">{u.name}</td>
                <td className="p-3">{u.email}</td>
                <td className="p-3 capitalize">{u.role}</td>
                <td className="p-3 text-right"><button className="btn btn-outline" onClick={()=>remove(u.id)}>Remover</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
