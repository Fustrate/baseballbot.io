const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.insert(
  'IgnorePlugin', new webpack.IgnorePlugin(/^\.\/locale$/, /moment$/)
)

module.exports = environment
