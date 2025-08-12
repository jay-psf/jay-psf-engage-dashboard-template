import type { Config } from "tailwindcss";

export default {
  darkMode: ["class"],
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./styles/**/*.css"],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: "var(--brand-primary)",
          600: "var(--brand-primary-600)",
          accent: "var(--brand-accent)",
          "accent-600": "var(--brand-accent-600)",
        },
        panel: "var(--panel)",
        "panel-2": "var(--panel-2)",
        card: "var(--card)",
        text: "var(--text)",
        muted: "var(--muted)",
        border: "var(--border)",
        ring: "var(--ring)",
        success: "var(--success)",
        warning: "var(--warning)",
        danger: "var(--danger)",
      },
      boxShadow: {
        soft: "0 8px 30px rgba(2,6,23,0.25)"
      },
      borderRadius: {
        xl: "1rem",
        "2xl": "1.25rem",
      }
    },
  },
  plugins: [],
} satisfies Config;
