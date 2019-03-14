process.env.NODE_ENV = process.env.NODE_ENV || 'production';

const SpeedMeasurePlugin = require('speed-measure-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const environment = require('./environment');

const smp = new SpeedMeasurePlugin();

// Disable sourcemaps and mangling
const terser = new TerserPlugin({
  parallel: true,
  cache: true,
  sourceMap: false,
  terserOptions: {
    parse: {
      // Let terser parse ecma 8 code but always output ES5 compliant code for older browsers
      ecma: 8,
    },
    compress: {
      comparisons: false,
      defaults: false,
      ecma: 5,
      keep_classnames: true,
      keep_fnames: true,
      warnings: false,
    },
    mangle: false,
    output: {
      ecma: 5,
      comments: false,
      ascii_only: true,
    },
  },
});

environment.config.optimization.minimizer = [terser];

module.exports = smp.wrap(environment.toWebpackConfig());
