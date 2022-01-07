// Font Awesome hard-codes "../webfonts/" into the path, but that confuses Sprockets.
const regex = /url\("..\/webfonts\/([^)]+)"\)/g;

module.exports = () => ({
  postcssPlugin: 'postcss-fa-font-urls',
  Declaration(decl) {
    if (decl.value.includes('url("../webfonts')) {
      decl.value = decl.value.replace(regex, (value, filename) => `url("${filename}")`);
    }
  },
});

module.exports.postcss = true;
