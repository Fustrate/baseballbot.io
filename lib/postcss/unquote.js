const regex = /unquote\(([^)]+)\)/g;

const unquote = () => ({
  postcssPlugin: 'postcss-unquote',
  Declaration(decl) {
    if (regex.test(decl.value)) {
      decl.value = decl.value.replaceAll(regex, (value) => value.slice(1, -1));
    }
  },
});

unquote.postcss = true;

export default unquote;
