const regex = /url\("..\/webfonts\/([^)]+)"\)/g;

module.exports = () => ({
  postcssPlugin: 'postcss-fa-font-urls',
  Declaration(decl) {
    if (regex.test(decl.value)) {
      decl.value = decl.value.replace(regex, (value, filename) => `url("${filename}")`);

      // throw new Error(decl.value);
    }
  },
});

module.exports.postcss = true;
