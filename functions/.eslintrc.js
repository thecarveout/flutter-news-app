// /Users/jeromehalligan/dev/functions/.eslintrc.js
module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended", // This might pull in some TS rules
  ],

  ignorePatterns: [
    "/lib/**/*", // Ignore compiled JS files
  ],
  plugins: [
    "@typescript-eslint",
    "import",
  ],
  rules: {
    "quotes": ["error", "double"],
    "import/no-unresolved": 0,
    "indent": ["error", 2],
    "max-len": ["error", { "code": 160, "ignoreUrls": true }],
    "object-curly-spacing": ["error", "always"],
    "padded-blocks": ["error", "never"],
    "eol-last": ["error", "always"],
    // You might also need to adjust:
    "@typescript-eslint/no-explicit-any": "off", // Often useful in functions
    "@typescript-eslint/no-var-requires": "off",
    "@typescript-eslint/explicit-module-boundary-types": "off",
  },
  // THIS IS THE CRUCIAL PART: 'overrides'
  overrides: [
    {
      files: ["*.ts"], // ONLY apply TypeScript-specific settings to .ts files
      parser: "@typescript-eslint/parser", // Specify the parser for TS files
      parserOptions: {
        project: ["tsconfig.json", "tsconfig.dev.json"],
        sourceType: "module",
      },
      rules: {
        // Any TypeScript-specific rules you want
      },
    },
    // No specific 'parserOptions.project' needed for .js files
    // as they are not part of a TypeScript project context for linting.
    // If you need specific JS rules, you can add another block:
    /*
    {
      files: ["*.js"],
      rules: {
        // Javascript specific rules
      }
    }
    */
  ],
};
