const { webpackConfig, merge, config } = require('@rails/webpacker');
const ForkTSCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');
const { ProvidePlugin } = require('webpack');

const {
  basename,
  dirname,
  join,
  relative,
  resolve,
} = require('path');
const extname = require('path-complete-extname');
const { sync: globSync } = require('glob');

webpackConfig.module.rules.map((module) => {
  if (module.test?.toString()?.includes('css')) {
    module.use.splice(-1, 0, { loader: require.resolve('resolve-url-loader') });
  }

  return module;
});

// Webpacker 6.0.0.rc6 changed the glob from **/*.* to *.*, so we need to change it back
function getEntryObject() {
  const entries = {};
  const rootPath = join(config.source_path, config.source_entry_path);

  globSync(`${rootPath}/**/*.*`).forEach((path) => {
    const namespace = relative(join(rootPath), dirname(path));
    const name = join(namespace, basename(path, extname(path)));
    let assetPaths = resolve(path);

    // Allows for multiple filetypes per entry (https://webpack.js.org/guides/entry-advanced/)
    // Transforms the config object value to an array with all values under the same name
    let previousPaths = entries[name];

    if (previousPaths) {
      previousPaths = Array.isArray(previousPaths) ? previousPaths : [previousPaths];
      previousPaths.push(assetPaths);
      assetPaths = previousPaths;
    }

    entries[name] = assetPaths;
  });

  return entries;
}

const newConfig = merge(webpackConfig, {
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

// Don't allow this to be merged; merging creates duplicates.
newConfig.entry = getEntryObject();

module.exports = newConfig;
