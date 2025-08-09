# Engage – Codespaces Template

Template mínimo para abrir **direto no GitHub Codespaces**, rodar `pnpm dev` e fazer deploy na **Vercel**.

## Como usar
1) Crie um novo repositório no GitHub e **faça upload** destes arquivos (ou envie o `.zip`).
2) Clique em **Code → Create codespace on main**.
3) Quando o Codespaces abrir, o `postCreateCommand` já vai instalar as dependências.
4) Rode `pnpm dev` no terminal.
5) Clique no link de **Port Forwarding** para abrir a aplicação no navegador.
6) Conecte o repositório na **Vercel** e faça deploy (Next.js é detectado automaticamente).

## Stack
- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS (dark mode ready)
- Codespaces (devcontainer)
- pnpm

## Próximos passos
- Use este repositório como base para colar o código do seu dashboard avançado.
- Opcional: adicione ESLint/Prettier, Zustand, TanStack Table, Recharts etc. conforme a necessidade.
