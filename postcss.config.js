const path = require('path');
const autoprefixer = require('autoprefixer');

const postcssImport = require('postcss-import');
const postcssFlexbugsFixes = require('postcss-flexbugs-fixes');
const postcssPresetEnv = require('postcss-preset-env');
const postcssMixins = require('postcss-mixins');
const postcssColorMod = require('postcss-color-mod-function');

const postcssAdvancedVars = require('postcss-advanced-variables');
const postcssNested = require('postcss-nested');
const postcssMinify = require('postcss-minify');

// Custom postcss plugins
const remCalc = require('./lib/postcss/rem-calc');
const media = require('./lib/postcss/media');
const faVar = require('./lib/postcss/fa-var');
const faFontUrls = require('./lib/postcss/fa-font-urls');

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
    postcssColorMod,
    faVar,
    media,
    faFontUrls,
    postcssPresetEnv({ autoprefixer: { flexbox: 'no-2009' }, stage: 3 }),
    autoprefixer,
    (isProduction && postcssMinify),
  ],
};
