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
  root: true,
  rules: {
    /*
    * Disabled Rules
    */
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

    // This is just ridiculous - can't even assign to a property of a parameter
    'no-param-reassign': 'off',

    // I'm just not there yet on types
    '@typescript-eslint/no-explicit-any': 'off',

    /*
    * Tweak the defaults
    */

    'class-methods-use-this': ['error', {
      exceptMethods: ['updateRow'],
    }],

    'import/extensions': ['error', 'ignorePackages', { js: 'never', ts: 'never' }],

    // Require all comments that aren't region markers to start with "// "
    'spaced-comment': ['error', 'always', { markers: ['#region', '#endregion'] }],

    '@typescript-eslint/consistent-type-definitions': 'warn',

    '@typescript-eslint/explicit-member-accessibility': 'warn',

    '@typescript-eslint/member-delimiter-style': 'warn',

    '@typescript-eslint/member-ordering': ['warn', {
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
    }],

    '@typescript-eslint/prefer-optional-chain': 'warn',

    // https://github.com/eslint/eslint/issues/13957
    indent: 'off',
    '@typescript-eslint/indent': ['error', 2],
  },
  settings: {
    'import/resolver': {
      typescript: {
        alwaysTryTypes: true,
        project: './app/frontend',
      },
    },
  },
  overrides: [
    {
      files: ['app/frontend/stylesheets/variables.js', 'lib/yarn/**/*.js'],
      rules: {
        '@typescript-eslint/explicit-function-return-type': 'off',
        '@typescript-eslint/explicit-module-boundary-types': 'off',
        '@typescript-eslint/no-var-requires': 'off',
      },
    },
    {
      files: ['lib/postcss/**/*.js', 'postcss.config.js'],
      rules: {
        '@typescript-eslint/no-var-requires': 'off',
      },
    },
  ],
};
