const postcssImport = require('postcss-import');
const postcssFlexbugsFixes = require('postcss-flexbugs-fixes');
const postcssPresetEnv = require('postcss-preset-env');

module.exports = {
  plugins: [
    postcssImport,
    postcssFlexbugsFixes,
    postcssPresetEnv({ autoprefixer: { flexbox: 'no-2009' }, stage: 3 }),
  ],
};
