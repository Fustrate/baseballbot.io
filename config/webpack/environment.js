const { environment } = require('@rails/webpacker');
const webpack = require('webpack'); // eslint-disable-line import/no-extraneous-dependencies
const SpeedMeasurePlugin = require('speed-measure-webpack-plugin');

environment.plugins.insert(
  'IgnorePlugin', new webpack.IgnorePlugin(/^\.\/locale$/, /moment$/),
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

module.exports = environment;
