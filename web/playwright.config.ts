import { defineConfig } from "@playwright/test";

/**
 * End-to-end checks of the built site. The preview server serves `build/client`, so the suite runs
 * the same bundle that is deployed. Images are stubbed per test; nothing is fetched from GitHub.
 */
export default defineConfig({
  testDir: "e2e",
  // Two workers keep the suite stable: each page mounts 600 cards, and a browser per core starves
  // the same renderer the assertions wait on.
  workers: 2,
  expect: { timeout: 10_000 },
  use: {
    baseURL: "http://localhost:4173",
  },
  webServer: {
    command: "bun run build && bun run preview",
    url: "http://localhost:4173",
    reuseExistingServer: false,
    timeout: 180_000,
  },
});
