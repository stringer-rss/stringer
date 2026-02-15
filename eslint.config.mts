import globals from "globals";
import importPlugin from "eslint-plugin-import";
import vitest from "eslint-plugin-vitest";
import js from "@eslint/js";
import stylistic from "@stylistic/eslint-plugin";
import tseslint from "typescript-eslint";
import {defineConfig} from "eslint/config";
import sortKeysFix from "eslint-plugin-sort-keys-fix";
import eslintTodo from "./.eslint_todo";

export default defineConfig([
  js.configs.all,
  tseslint.configs.all,
  importPlugin.flatConfigs.recommended,
  vitest.configs.all,
  stylistic.configs.all,
  {
    ignores: [
      ".eslint_todo.ts",
      "app/assets/builds/**",
      "coverage/**",
      "public/**",
      "vendor/**",
    ],
  },
  {
    files: ["**/*.{js,mjs,cjs,ts,mts,cts}"],
    languageOptions: {
      globals: globals.browser,
      parserOptions: {
        projectService: {
          allowDefaultProject: ["stylelint.config.mjs"],
        },
      },
    },
    plugins: {
      importPlugin,
      "sort-keys-fix": sortKeysFix,
      vitest,
    },
    rules: {
      "@stylistic/array-element-newline": ["error", "consistent"],
      "@stylistic/brace-style": ["error", "1tbs", {allowSingleLine: true}],
      "@stylistic/comma-dangle": ["error", "always-multiline"],
      "@stylistic/function-call-argument-newline": ["error", "consistent"],
      "@stylistic/indent": ["error", 2],
      "@stylistic/max-len": ["error", 80, {ignoreUrls: true}],
      "@stylistic/object-property-newline":
        ["error", {allowAllPropertiesOnSameLine: true}],
      "@stylistic/padded-blocks": ["error", "never"],
      "@stylistic/quote-props": ["error", "as-needed", {keywords: true}],
      "@stylistic/space-before-function-paren":
        ["error", {anonymous: "always", named: "never"}],
      "@typescript-eslint/consistent-indexed-object-style":
        ["error", "index-signature"],
      "@typescript-eslint/consistent-type-assertions":
        ["error", {assertionStyle: "never"}],
      "@typescript-eslint/explicit-member-accessibility": "off",
      "@typescript-eslint/naming-convention": "off",
      "@typescript-eslint/no-magic-numbers": "off",
      "@typescript-eslint/prefer-readonly-parameter-types": "off",
      "arrow-body-style": ["error", "always"],
      "func-style": ["error", "declaration"],
      "max-len": ["error", 84, {ignoreUrls: true}],
      "no-duplicate-imports": ["error", {allowSeparateTypeImports: true}],
      "no-magic-numbers": "off",
      "no-undefined": "off",
      "no-var": "off",
      "one-var": ["error", "never"],
      "sort-imports":
        ["error", {ignoreCase: true, ignoreDeclarationSort: true}],
      "sort-keys": ["error", "asc", {caseSensitive: false, natural: true}],
      "sort-keys-fix/sort-keys-fix":
        ["error", "asc", {caseSensitive: false, natural: true}],
      "vitest/consistent-test-it":
        ["error", {fn: "it", withinDescribe: "it"}],
      "vitest/prefer-expect-assertions": "off",
      "vitest/prefer-to-be-falsy": "off",
      "vitest/prefer-to-be-truthy": "off",
      "vitest/require-top-level-describe": "off",
    },
    settings: {
      "import/resolver": {
        typescript: {
          alwaysTryTypes: true,
        },
      },
    },
  },
  {
    files: ["spec/javascript/setup.ts"],
    rules: {
      "vitest/no-hooks": "off",
      "vitest/no-standalone-expect": "off",
    },
  },
  {
    files: ["spec/javascript/support/**/*"],
    rules: {
      "vitest/no-hooks": "off",
    },
  },
  {
    files: ["app/javascript/**/*.ts"],
    rules: {
      "vitest/require-hook": "off",
    },
  },
  ...eslintTodo,
]);
