import "../../styles/globals.css";

export const metadata = { title: "Login • Engage" };

export default function LoginLayout({ children }: { children: React.ReactNode }){
  return (
    <html lang="pt-BR">
      <body className="min-h-screen grid place-items-center p-6">{children}</body>
    </html>
  );
}
