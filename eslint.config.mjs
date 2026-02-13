import js from "@eslint/js";
import globals from "globals";

export default [
  js.configs.recommended,
  {
    languageOptions: {
      sourceType: "script",
      globals: {
        ...globals.browser,
        Backbone: "readonly",
        _: "readonly",
        $: "readonly",
        jQuery: "readonly",
        Mousetrap: "readonly",
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
      globals: {
        describe: "readonly",
        it: "readonly",
        before: "readonly",
        beforeEach: "readonly",
        afterEach: "readonly",
        sinon: "readonly",
        chai: "readonly",
        mocha: "readonly",
        initMochaPhantomJS: "readonly",
        Story: "readonly",
        StoryView: "readonly",
        StoryList: "readonly",
      },
    },
  },
  {
    ignores: ["vendor/", "coverage/", "spec/javascript/support/", "public/"],
  },
];
