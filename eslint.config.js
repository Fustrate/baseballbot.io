import path from 'node:path';

import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';

import lodash from 'eslint-plugin-lodash';
import stylistic from '@stylistic/eslint-plugin';
import unicorn from 'eslint-plugin-unicorn';

import globals from 'globals';

export default tseslint.config(
  {
    ignores: [
      '.yarn',
      'app/assets',
      'app/frontend/utilities/routes.ts',
      'node_modules',
      'public',
    ],
  },
  eslint.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  ...tseslint.configs.stylisticTypeChecked,
  stylistic.configs.customize({
    indent: 2,
    semi: true,
    braceStyle: '1tbs',
    quoteProps: 'consistent-as-needed',
    arrowParens: true,
    commaDangle: 'always-multiline',
  }),
  unicorn.configs['flat/recommended'],
  {
    // ----------------------------------------------- Typescript Rules ------------------------------------------------
    rules: {
      // I'm just not there yet on types
      // https://typescript-eslint.io/rules/
      '@typescript-eslint/no-explicit-any': 'off',
      '@typescript-eslint/no-unsafe-argument': 'off',
      '@typescript-eslint/no-unsafe-assignment': 'off',
      '@typescript-eslint/no-unsafe-call': 'off',
      '@typescript-eslint/no-unsafe-member-access': 'off',
      '@typescript-eslint/require-await': 'off',

      // This requires strictNullChecks to be enabled in tsconfig.json
      '@typescript-eslint/prefer-nullish-coalescing': 'off',

      '@typescript-eslint/consistent-type-definitions': 'warn',

      '@typescript-eslint/explicit-member-accessibility': 'warn',

      '@typescript-eslint/member-delimiter-style': 'warn',

      '@typescript-eslint/member-ordering': ['warn', {
        default: [
          'static-field', 'public-field', 'protected-field', 'private-field',
          'constructor',
          'static-method', 'public-method', 'protected-method', 'private-method',
          'abstract-method',
        ],
      }],

      '@typescript-eslint/prefer-optional-chain': 'warn',
    },
    languageOptions: {
      parserOptions: {
        project: './tsconfig.json',
        tsconfigRootDir: path.join(path.resolve('.'), 'app', 'frontend'),
      },
    },
  },
  {
    // ------------------------------------------------- Lodash Rules --------------------------------------------------
    plugins: { lodash },
    rules: {
      // eslint-plugin-lodash doesn't have a flat config option (yet?)
      ...lodash.configs.recommended.rules,

      // Wants to use _.constant('constant') instead of a getter that returns a constant
      'lodash/prefer-constant': 'off',

      // `_.pull(obj, 'item')` mutates the collection passed, this prefers `obj = _.without(obj, 'item')`
      'lodash/prefer-immutable-method': 'off',

      // I prefer to use native methods when possible.
      'lodash/prefer-lodash-method': 'off',
      'lodash/prefer-lodash-typecheck': 'off',

      // Recommends `_.map(col, 'owner.name')` instead of `col.map((prop) => prop.owner.name)`
      'lodash/prop-shorthand': 'off',
    },
  },
  {
    // ------------------------------------------------- Unicorn Rules -------------------------------------------------
    rules: {
      // I use abbreviations, sue me.
      // https://github.com/sindresorhus/eslint-plugin-unicorn/blob/main/docs/rules/prevent-abbreviations.md
      'unicorn/prevent-abbreviations': 'off',
    },
  },
  {
    // ---------------------------------------------- Tweak the defaults -----------------------------------------------
    rules: {
      // Ignore class definition lines that are too long
      // https://eslint.org/docs/latest/rules/max-len
      'max-len': ['error', 120, 2, {
        ignoreUrls: true,
        ignoreComments: false,
        ignoreStrings: true,
        ignoreTemplateLiterals: true,
        ignoreRegExpLiterals: true,
        ignorePattern: '^export default class.*implements',
      }],

      // https://eslint.org/docs/latest/rules/spaced-comment
      'spaced-comment': ['error', 'always', { markers: ['#region', '#endregion'] }],

      // https://eslint.style/rules/js/quotes
      '@stylistic/quotes': ['error', 'single', { avoidEscape: true }],
    },
  },
  {
    // Rules and tweaks that only need to be applied to the frontend code
    files: ['app/frontend/**/*.ts'],
    rules: {
      // https://github.com/sindresorhus/eslint-plugin-unicorn/blob/main/docs/rules/filename-case.md
      'unicorn/filename-case': ['error', { case: 'snakeCase' }],

      // This complains about bound methods in addEventListener
      // https://typescript-eslint.io/rules/no-misused-promises
      '@typescript-eslint/no-misused-promises': ['error', {
        checksVoidReturn: {
          arguments: false,
        },
      }],

      // I want to allow 0 spaces between property definitions.
      // https://eslint.org/docs/latest/rules/lines-between-class-members
      'lines-between-class-members': 'off',

      // https://eslint.org/docs/latest/rules/no-alert
      'no-alert': 'off',

      // This is just ridiculous - can't even assign to a property of a parameter
      // https://eslint.org/docs/latest/rules/no-param-reassign
      'no-param-reassign': 'off',

      // `for (const x of y)` is restricted by airbnb's `no-restricted-syntax` rule.
      // https://github.com/sindresorhus/eslint-plugin-unicorn/blob/main/docs/rules/no-array-for-each.md
      'unicorn/no-array-for-each': 'off',

      // When nodes are detached/attached, the dataset disappears whereas data- attributes live on.
      // https://github.com/sindresorhus/eslint-plugin-unicorn/blob/main/docs/rules/prefer-dom-node-dataset.md
      'unicorn/prefer-dom-node-dataset': 'off',

      // Passing a function to methods like `filter` can pass other arguments silently.
      // https://github.com/sindresorhus/eslint-plugin-unicorn/blob/main/docs/rules/no-array-callback-reference.md
      'unicorn/no-array-callback-reference': 'off',

      // This is in ES2021, but we target ES6
      // https://github.com/sindresorhus/eslint-plugin-unicorn/blob/main/docs/rules/prefer-string-replace-all.md
      'unicorn/prefer-string-replace-all': 'off',

      // `window.prompt` returns `null` when you click the cancel button. I don't get this rule.
      // https://github.com/sindresorhus/eslint-plugin-unicorn/blob/main/docs/rules/no-null.md
      'unicorn/no-null': 'off',
    },
    languageOptions: {
      parserOptions: {
        project: './tsconfig.json',
        tsconfigRootDir: path.join(path.resolve('.'), 'app', 'frontend'),
      },
    },
  },
  {
    // Disable type checking rules in plain JS files
    files: ['**/*.config.{js,ts}', 'lib/**/*.js'],
    extends: [tseslint.configs.disableTypeChecked],
  },
  {
    // Don't worry about quoted properties in auto-generated code
    files: ['app/frontend/utilities/constants.ts'],
    rules: {
      // https://eslint.style/rules/js/quote-props
      '@stylistic/quote-props': ['error', 'as-needed'],
    },
  },
  {
    // Make sure we can access things like `process` in certain files.
    files: ['postcss.config.js', 'lib/yarn/esbuild.js'],
    languageOptions: {
      globals: globals.node,
    },
  },
);
