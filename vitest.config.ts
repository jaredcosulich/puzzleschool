import { defineConfig } from 'vitest/config';

// Component unit tests run under jsdom so React islands can render into a DOM
// without a browser. Astro `.astro` files are not imported here — they are
// exercised through captured scenarios in the live preview, not vitest.
export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
    include: ['src/**/*.test.{ts,tsx}'],
  },
});
