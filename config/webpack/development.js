/* eslint-disable @typescript-eslint/no-var-requires */
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const { merge } = require('@rails/webpacker');
const webpackConfig = require('./base');

module.exports = merge(webpackConfig, { target: 'web' });
