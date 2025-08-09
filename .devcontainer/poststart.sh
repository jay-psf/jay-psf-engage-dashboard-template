#!/usr/bin/env bash
set -e
cd /workspaces/jay-psf-engage-dashboard-template
rm -f postcss.config.js postcss.config.cjs postcss.config.json || true
cat > postcss.config.mjs << 'EOC'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
EOC

cat > next.config.mjs << 'EOC'
/** @type {import("next").NextConfig} */
const nextConfig = {};
export default nextConfig;
EOC

rm -rf .next
pnpm dev
