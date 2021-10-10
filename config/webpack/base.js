const { webpackConfig, merge } = require('@rails/webpacker');
const ForkTSCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');
const { ProvidePlugin } = require('webpack');

webpackConfig.module.rules.map((module) => {
  if (module.test?.toString()?.includes('css')) {
    module.use.splice(-1, 0, { loader: require.resolve('resolve-url-loader') });
  }

  return module;
});

module.exports = merge(webpackConfig, {
  module: {
    rules: [
      {
        // Uncaught TypeError: class constructors must be invoked with 'new'
        exclude: /node_modules\/(?!@fustrate)/,
        include: /node_modules/,
        test: /\.js$/,
        use: [
          {
            loader: 'babel-loader',
            options: {
              babelrc: false,
              cacheCompression: process.env.NODE_ENV === 'production',
              cacheDirectory: true,
              compact: false,
              presets: [['@babel/preset-env', { modules: false }]],
            },
          },
        ],
      },
    ],
  },
  performance: {
    // Don't warn about maps and fonts
    assetFilter: (assetFilename) => !(/\.(?:map|ttf|svg|gz)$/.test(assetFilename)),
    hints: false,
  },
  plugins: [
    new ForkTSCheckerWebpackPlugin({ typescript: { configFile: 'app/packs/tsconfig.json' } }),
    new ProvidePlugin({
      Buffer: ['buffer', 'Buffer'],
      process: 'process/browser',
    }),
  ],
  resolve: {
    alias: {
      js: 'javascript',
      models: 'javascript/models',
    },
    extensions: ['.css'],
    fallback: {
      assert: require.resolve('assert/'),
      buffer: require.resolve('buffer/'),
      stream: require.resolve('stream-browserify'),
    },
  },
  // devServer: {
  //   stats: {
  //     children: true,
  //   },
  // },
});
