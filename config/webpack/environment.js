const { environment } = require('@rails/webpacker');
const webpack = require('webpack'); // eslint-disable-line import/no-extraneous-dependencies

const erb = require('./loaders/erb');

environment.loaders.append('erb', erb);

environment.plugins.insert(
  'IgnorePlugin', new webpack.IgnorePlugin(/^\.\/locale$/, /moment$/),
);

environment.config.merge({
  optimization: {
    splitChunks: {
      chunks: 'all',
    },
  },
});

module.exports = environment;
