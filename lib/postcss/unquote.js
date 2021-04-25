const regex = /unquote\(([^)]+)\)/g;

module.exports = () => ({
  postcssPlugin: 'postcss-unquote',
  Declaration(decl) {
    if (regex.test(decl.value)) {
      decl.value = decl.value.replace(regex, (value) => value.slice(1, -1));
    }
  },
});

module.exports.postcss = true;
