import js from "@eslint/js";
import globals from "globals";

export default [
  js.configs.recommended,
  {
    files: ["app/javascript/**"],
    languageOptions: {
      sourceType: "module",
      globals: {
        ...globals.browser,
      },
    },
    rules: {
      "no-var": "off",
      "no-unused-vars": "warn",
    },
  },
  {
    files: ["spec/javascript/spec/**"],
    languageOptions: {
      sourceType: "module",
      globals: {
        ...globals.browser,
        jQuery: "readonly",
        Story: "readonly",
        StoryView: "readonly",
        StoryList: "readonly",
      },
    },
  },
  {
    ignores: ["vendor/", "coverage/", "spec/javascript/support/", "public/", "app/assets/builds/"],
  },
];
