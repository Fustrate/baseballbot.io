const PnpWebpackPlugin = require('pnp-webpack-plugin');

module.exports = {
  test: /\.ts$/,
  use: [
    {
      loader: 'ts-loader',
      options: PnpWebpackPlugin.tsLoaderOptions(),
    },
  ],
};
