/* eslint-disable import/no-extraneous-dependencies */
const postcssImport = require('postcss-import');
const postcssFlexbugsFixes = require('postcss-flexbugs-fixes');
const postcssPresetEnv = require('postcss-preset-env');
/* eslint-enable import/no-extraneous-dependencies */

module.exports = {
  plugins: [
    postcssImport,
    postcssFlexbugsFixes,
    postcssPresetEnv({ autoprefixer: { flexbox: 'no-2009' }, stage: 3 }),
  ],
};
