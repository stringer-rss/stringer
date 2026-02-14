import path from "node:path";
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    alias: {
      jquery: path.resolve(__dirname, "node_modules/jquery/jquery.js"),
      bootstrap: path.resolve(__dirname, "node_modules/bootstrap/dist/js/bootstrap.js"),
      mousetrap: path.resolve(__dirname, "node_modules/mousetrap/mousetrap.js"),
      "jquery-visible": path.resolve(__dirname, "node_modules/jquery-visible/jquery.visible.min.js"),
    },
  },
  test: {
    environment: "jsdom",
    setupFiles: ["spec/javascript/setup.js"],
    include: ["spec/javascript/**/*_spec.js"],
    restoreMocks: true,
  },
});
