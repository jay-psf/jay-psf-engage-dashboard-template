export default function Denied() {
  return (
    <div className="p-6 max-w-xl">
      <h1 className="text-xl font-semibold mb-2">Acesso negado</h1>
      <p className="text-neutral-700">
        Você não tem permissão para acessar esta área. Faça login com o perfil correto.
      </p>
    </div>
  );
}
