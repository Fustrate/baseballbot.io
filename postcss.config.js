const path = require('path');

const postcssImport = require('postcss-import');
const postcssFlexbugsFixes = require('postcss-flexbugs-fixes');
const postcssPresetEnv = require('postcss-preset-env');
const postcssMixins = require('postcss-mixins');
const postcssColorMod = require('postcss-color-mod-function');

const postcssAdvancedVars = require('postcss-advanced-variables');
const postcssNested = require('postcss-nested');

// Custom postcss plugins
const remCalc = require('./lib/postcss/rem-calc');
const media = require('./lib/postcss/media');
const faVar = require('./lib/postcss/fa-var');

const variables = require('./app/packs/stylesheets/variables');

// We're literally only using variables here
const variablesConfig = {
  variables,
  disable: ['@content', '@each', '@else', '@if', '@include', '@import', '@for', '@mixin'],
};

// Run variables multiple times
module.exports = {
  plugins: [
    postcssImport,
    postcssFlexbugsFixes,
    // postcssAdvancedVars(variablesConfig),
    remCalc,
    // postcss-mixins must come before postcss-simple-vars and postcss-nested
    postcssMixins({ mixinsDir: path.join(__dirname, 'lib', 'postcss', 'mixins') }),
    postcssAdvancedVars(variablesConfig),
    postcssNested,
    postcssColorMod,
    faVar,
    media,
    postcssPresetEnv({ autoprefixer: { flexbox: 'no-2009' }, stage: 3 }),
  ],
};
