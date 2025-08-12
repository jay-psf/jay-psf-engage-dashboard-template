export default function Overview() {
  return (
    <section className="grid gap-4 md:grid-cols-2">
      <div className="p-4 border rounded bg-white">
        <h2 className="font-semibold mb-2">Status do Contrato</h2>
        <ul className="text-sm text-neutral-700">
          <li>Vigência: 2025-01-01 a 2025-12-31</li>
          <li>Pago: R$ 500.000</li>
          <li>Em aberto: R$ 300.000</li>
        </ul>
      </div>
      <div className="p-4 border rounded bg-white">
        <h2 className="font-semibold mb-2">Próximos marcos</h2>
        <ul className="text-sm text-neutral-700 list-disc pl-5">
          <li>Envio de peças de mídia – D-7</li>
          <li>Check de operação – D-2</li>
        </ul>
      </div>
    </section>
  );
}
