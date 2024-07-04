const regex = /rem-calc\(([^)]+)\)/g;

const remCalc = (opts = {}) => {
  const remBase = Number(opts?.remBase || 16);

  return {
    postcssPlugin: 'postcss-media',
    Declaration(decl) {
      if (regex.test(decl.value)) {
        decl.value = decl.value.replaceAll(regex, (match, value) => value
          .split(/\W+/)
          .map((number) => `${Number(number) / remBase}rem`)
          .join(' '));
      }
    },
  };
};

remCalc.postcss = true;

export default remCalc;
