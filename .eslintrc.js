module.exports = {
  env: {
    browser: true,
    node: true,
  },
  extends: [
    'airbnb-base',
    'plugin:lodash/recommended',
    'plugin:@typescript-eslint/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    allowImportExportEverywhere: true,
  },
  plugins: ['import', 'lodash', '@typescript-eslint'],
  rules: {
    /*
    * Disabled Rules
    */
    'class-methods-use-this': 'off',

    // I want to allow 0 spaces between property definitions.
    'lines-between-class-members': 'off',

    // Wants to use _.constant('constant') instead of a getter that returns a constant
    'lodash/prefer-constant': 'off',

    // `pull(obj, 'item')` mutates the collection passed, this prefers `obj = without(obj, 'item')`
    'lodash/prefer-immutable-method': 'off',

    // I prefer to use native methods when possible.
    'lodash/prefer-lodash-method': 'off',

    // Empty functions are fine by me.
    'lodash/prefer-noop': 'off',

    // Recommends `_.map(col, 'owner.name')` instead of `col.map((prop) => prop.owner.name)`
    'lodash/prop-shorthand': 'off',

    'no-alert': 'off',

    // This is just ridiculous - can't even assign to a property of a parameter
    'no-param-reassign': 'off',

    // A few third party packages use snake case
    '@typescript-eslint/camelcase': 'off',

    // I'm just not there yet on types
    '@typescript-eslint/no-explicit-any': 'off',

    /*
    * Tweak the defaults
    */

    'import/extensions': ['error', 'ignorePackages', { js: 'never', ts: 'never' }],

    // Ignore class definition lines that are too long
    'max-len': ['error', 120, 2, {
      ignorePattern: '^export default class.*implements',
      ignoreUrls: true,
      ignoreComments: false,
      ignoreRegExpLiterals: true,
      ignoreStrings: true,
      ignoreTemplateLiterals: true,
    }],

    'spaced-comment': ['error', 'always', { markers: ['#region', '#endregion'] }],

    '@typescript-eslint/consistent-type-definitions': 'warn',
    '@typescript-eslint/explicit-member-accessibility': 'warn',
    '@typescript-eslint/member-delimiter-style': 'warn',
    '@typescript-eslint/member-ordering': [
      'warn',
      {
        default: [
          'static-field',
          'public-field',
          'protected-field',
          'private-field',

          'constructor',

          'static-method',
          'public-method',
          'protected-method',
          'private-method',

          'abstract-method',
        ],
      },
    ],
    '@typescript-eslint/prefer-optional-chain': 'warn',
    // '@typescript-eslint/restrict-template-expressions': 'warn',
  },
  settings: {
    'import/extensions': ['.js', '.ts'],
    'import/parsers': {
      '@typescript-eslint/parser': ['.ts'],
    },
    'import/resolver': {
      'babel-module': {},
      typescript: {
        alwaysTryTypes: true,
        project: './app/packs',
      },
    },
  },
  overrides: [
    {
      files: ['app/packs/stylesheets/variables.js', 'lib/yarn/**/*.js'],
      rules: {
        '@typescript-eslint/explicit-function-return-type': 0,
        '@typescript-eslint/explicit-module-boundary-types': 0,
        '@typescript-eslint/no-var-requires': 0,
      },
    },
    {
      files: [
        'config/webpack/**/*.js',
        'lib/postcss/**/*.js',
        'postcss.config.js',
      ],
      rules: {
        '@typescript-eslint/no-var-requires': 0,
      },
    },
  ],
};
