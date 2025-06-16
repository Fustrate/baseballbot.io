import tailwindcss from '@tailwindcss/postcss';

import postcssMinify from '@csstools/postcss-minify';

export default {
  plugins: [tailwindcss, postcssMinify],
};
