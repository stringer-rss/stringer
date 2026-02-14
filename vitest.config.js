import path from "node:path";
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    alias: {
      jquery: path.resolve(__dirname, "node_modules/jquery/jquery.js"),
    },
  },
  test: {
    environment: "jsdom",
    setupFiles: ["spec/javascript/setup.js"],
    include: ["spec/javascript/**/*_spec.js"],
    restoreMocks: true,
  },
});
