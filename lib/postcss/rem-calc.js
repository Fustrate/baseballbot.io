const regex = /rem-calc\(([^)]+)\)/g;

module.exports = (opts = {}) => {
  const remBase = Number(opts?.remBase || 16);

  return {
    postcssPlugin: 'postcss-media',
    Declaration(decl) {
      if (regex.test(decl.value)) {
        decl.value = decl.value.replace(regex, (match, value) => value
          .split(/\W+/)
          .map((number) => `${Number(number) / remBase}rem`)
          .join(' '));
      }
    },
  };
};

module.exports.postcss = true;
