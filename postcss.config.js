const path = require('path');
const autoprefixer = require('autoprefixer');

const postcssAdvancedVars = require('postcss-advanced-variables');
const postcssFlexbugsFixes = require('postcss-flexbugs-fixes');
const postcssImport = require('postcss-import');
const postcssMinify = require('postcss-minify');
const postcssMixins = require('postcss-mixins');
const postcssNested = require('postcss-nested');
const postcssPresetEnv = require('postcss-preset-env');

// Custom postcss plugins
const colorMod = require('./lib/postcss/color-mod');
const faFontUrls = require('./lib/postcss/fa-font-urls');
const faVar = require('./lib/postcss/fa-var');
const media = require('./lib/postcss/media');
const remCalc = require('./lib/postcss/rem-calc');

const variables = require('./app/frontend/stylesheets/variables');

// We're literally only using variables here
const variablesConfig = {
  variables,
  disable: ['@content', '@each', '@else', '@if', '@include', '@import', '@for', '@mixin'],
};

const isProduction = true;

// Run variables multiple times
module.exports = {
  plugins: [
    postcssImport,
    postcssFlexbugsFixes,
    postcssAdvancedVars(variablesConfig),
    remCalc,
    // postcss-mixins must come before postcss-nested
    postcssMixins({ mixinsDir: path.join(__dirname, 'lib', 'postcss', 'mixins') }),
    postcssAdvancedVars(variablesConfig),
    postcssNested,
    colorMod,
    faVar,
    media,
    faFontUrls,
    postcssPresetEnv({ autoprefixer: { flexbox: 'no-2009' }, stage: 3 }),
    autoprefixer,
    (isProduction && postcssMinify),
  ],
};
