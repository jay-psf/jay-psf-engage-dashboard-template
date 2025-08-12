import type { Config } from 'tailwindcss'

export default {
  darkMode: 'class',
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}', './styles/**/*.css'],
  theme: {
    extend: {
      colors: {
        primary: 'hsl(var(--primary))',
        success: 'hsl(var(--success))',
        warning: 'hsl(var(--warning))',
        danger:  'hsl(var(--danger))',
        neutral: {
          50:  'hsl(var(--neutral-50))',
          100: 'hsl(var(--neutral-100))',
          200: 'hsl(var(--neutral-200))',
          300: 'hsl(var(--neutral-300))',
          400: 'hsl(var(--neutral-400))',
          500: 'hsl(var(--neutral-500))',
          600: 'hsl(var(--neutral-600))',
          700: 'hsl(var(--neutral-700))',
          800: 'hsl(var(--neutral-800))',
          900: 'hsl(var(--neutral-900))',
        }
      },
      borderRadius: { '2xl':'var(--radius-2xl)' }
    }
  },
  plugins: [],
} satisfies Config
