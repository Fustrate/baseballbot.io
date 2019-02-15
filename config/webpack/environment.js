const { environment } = require('@rails/webpacker');
const webpack = require('webpack');

const erb = require('./loaders/erb');

environment.plugins.insert(
  'IgnorePlugin', new webpack.IgnorePlugin(/^\.\/locale$/, /moment$/),
);

environment.loaders.append('erb', erb);

module.exports = environment;
