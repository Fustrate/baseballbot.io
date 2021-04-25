/* eslint-disable @typescript-eslint/no-var-requires */
const { webpackConfig, merge } = require('@rails/webpacker');
const ForkTSCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');
const { IgnorePlugin } = require('webpack'); // eslint-disable-line import/no-extraneous-dependencies

webpackConfig.module.rules.map((module) => {
  if (module.test?.toString()?.includes('css')) {
    module.use.splice(-1, 0, { loader: require.resolve('resolve-url-loader') });
  }

  return module;
});

webpackConfig.module.rules.push({
  test: /\.js$/,
  include: /node_modules/,
  exclude: /node_modules\/(?!@fustrate)/,
  use: [
    {
      loader: 'babel-loader',
      options: {
        babelrc: false,
        presets: [['@babel/preset-env', { modules: false }]],
        cacheDirectory: true,
        // cacheCompression: nodeEnv === 'production',
        compact: false,
        sourceMaps: false,
      },
    },
  ],
});

module.exports = merge(webpackConfig, {
  performance: {
    hints: false,
    maxEntrypointSize: 400000,
    // Don't warn about maps and fonts
    assetFilter: (assetFilename) => !(/\.(?:map|ttf|eot|svg|gz)$/.test(assetFilename)),
  },
  plugins: [
    new ForkTSCheckerWebpackPlugin({ typescript: { configFile: 'app/packs/tsconfig.json' } }),
    new IgnorePlugin(/^\.\/locale$/, /moment$/),
  ],
  resolve: {
    extensions: ['.css'],
    alias: {
      js: 'javascript',
      models: 'javascript/models',
    },
  },
});
