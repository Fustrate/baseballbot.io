import path from 'node:path';
import autoprefixer from 'autoprefixer';

import postcssAdvancedVars from 'postcss-advanced-variables';
import postcssFlexbugsFixes from 'postcss-flexbugs-fixes';
import postcssImport from 'postcss-import';
import postcssMinify from 'postcss-minify';
import postcssMixins from 'postcss-mixins';
import postcssNested from 'postcss-nested';
import postcssPresetEnv from 'postcss-preset-env';

// Custom postcss plugins
import colorMod from './lib/postcss/color-mod.js';
import media from './lib/postcss/media.js';
import remCalc from './lib/postcss/rem-calc.js';

import variables from './app/frontend/stylesheets/variables.js';

// We're literally only using variables here
const variablesConfig = {
  variables,
  disable: ['@content', '@each', '@else', '@if', '@include', '@import', '@for', '@mixin'],
};

const isProduction = true;

// Run variables multiple times
export default {
  plugins: [
    postcssImport,
    postcssFlexbugsFixes,
    postcssAdvancedVars(variablesConfig),
    remCalc,
    // postcss-mixins must come before postcss-nested
    postcssMixins({ mixinsDir: path.join(import.meta.dirname, 'lib', 'postcss', 'mixins') }),
    postcssAdvancedVars(variablesConfig),
    postcssNested,
    colorMod,
    media,
    postcssPresetEnv({ autoprefixer: { flexbox: 'no-2009' }, stage: 3 }),
    autoprefixer,
    (isProduction && postcssMinify),
  ],
};
