export default {
  extends: [
    "stylelint-config-standard",
    "stylelint-config-recess-order",
    "./.stylelint_todo.yml",
  ],
  ignoreFiles: [
    "app/assets/stylesheets/flat-ui-no-icons.css",
    "app/assets/stylesheets/font-awesome-min.css",
    "app/assets/stylesheets/lato-fonts.css",
    "app/assets/stylesheets/reenie-beanie-font.css",
    "coverage/**",
    "node_modules/**",
  ],
  plugins: ["stylelint-selector-bem-pattern"],
  rules: {
    "no-descending-specificity": null,
    "plugin/selector-bem-pattern": {
      preset: "bem",
    },
  },
};
