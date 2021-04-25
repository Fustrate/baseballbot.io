module.exports = (api) => {
  const validEnv = ['development', 'test', 'production'];
  const currentEnv = api.env();

  if (!validEnv.includes(currentEnv)) {
    const validEnvStrings = validEnv.map((str) => `"${str}"`).join(', ');

    throw new Error(`
      Please specify a valid NODE_ENV or BABEL_ENV environment variable. Valid values are ${validEnvStrings}.
      Instead, received: ${JSON.stringify(currentEnv)}.`);
  }

  const isTestEnv = api.env('test');

  let presetEnvSettings;

  if (isTestEnv) {
    presetEnvSettings = { targets: { node: 'current' } };
  } else {
    presetEnvSettings = {
      forceAllTransforms: true,
      useBuiltIns: 'entry',
      corejs: 3,
      modules: false,
      exclude: ['transform-typeof-symbol'],
    };
  }

  return {
    presets: [
      ['@babel/preset-env', presetEnvSettings],
      ['@babel/preset-typescript', { allExtensions: true, isTSX: true }],
    ],
    plugins: [
      'babel-plugin-macros',
      '@babel/plugin-syntax-dynamic-import',
      isTestEnv && 'babel-plugin-dynamic-import-node',
      '@babel/plugin-transform-destructuring',
      '@babel/plugin-transform-modules-commonjs',
      '@babel/plugin-proposal-export-default-from',
      '@babel/plugin-proposal-export-namespace-from',
      '@babel/plugin-proposal-optional-chaining',
      '@babel/plugin-proposal-logical-assignment-operators',
      ['@babel/plugin-proposal-class-properties', { loose: true }],
      ['@babel/plugin-proposal-object-rest-spread', { useBuiltIns: true }],
      ['@babel/plugin-transform-runtime', { helpers: false }],
      ['@babel/plugin-transform-regenerator', { async: false }],
      ['babel-plugin-module-resolver', {
        root: ['./app/packs/'],
        alias: {
          js: './app/packs/javascript/',
          models: './app/packs/javascript/models/',
        },
      }],
    ].filter(Boolean),
  };
};
