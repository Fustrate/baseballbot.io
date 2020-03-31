const { environment } = require('@rails/webpacker');
const { IgnorePlugin } = require('webpack'); // eslint-disable-line import/no-extraneous-dependencies
const SpeedMeasurePlugin = require('speed-measure-webpack-plugin');
const typescript = require('./loaders/typescript');

environment.plugins.insert(
  'IgnorePlugin', new IgnorePlugin(/^\.\/locale$/, /moment$/),
);

const smp = new SpeedMeasurePlugin();

environment.config.merge(smp.wrap({
  devtool: false,
  optimization: {
    splitChunks: {
      chunks: 'all',
    },
  },
  performance: {
    hints: false,
    maxEntrypointSize: 400000,
    // Don't warn about maps and fonts
    assetFilter: assetFilename => !(/\.(?:map|ttf|eot|svg|gz)$/.test(assetFilename)),
  },
}));

environment.loaders.prepend('typescript', typescript);

module.exports = environment;
