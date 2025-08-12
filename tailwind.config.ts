import type { Config } from "tailwindcss";

export default {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./styles/**/*.css",
  ],
  darkMode: ["class"],
  theme: {
    extend: {
      colors: {
        entourage: {
          // primária (acento) – ajustaremos depois com a paleta oficial
          primary: "#19C5D8",
          // background claro e escuro
          bg: {
            light: "#F5F8FB",
            dark: "#0E1217",
          },
          // cartões/contêiner
          surface: {
            light: "#FFFFFF",
            dark: "#151B22",
          },
          // bordas e linhas
          line: {
            light: "#E6ECF2",
            dark: "#233041",
          },
          // texto
          text: {
            light: "#0F172A",
            muteLight: "#475569",
            dark: "#F1F5F9",
            muteDark: "#94A3B8",
          },
        },
      },
      boxShadow: {
        soft: "0 8px 24px rgba(2, 12, 27, 0.06)",
      },
      borderRadius: {
        pill: "9999px",
        xl2: "1rem",
      },
    },
    fontFamily: {
      sans: ["var(--font-inter)", "system-ui", "ui-sans-serif", "Arial"],
    },
  },
  plugins: [],
} satisfies Config;
