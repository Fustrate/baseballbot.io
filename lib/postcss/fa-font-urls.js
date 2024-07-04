// Font Awesome hard-codes "../webfonts/" into the path, but that confuses Propshaft.
const regex = /url\("..\/webfonts\/([^)]+)"\)/g;

const faFontUrls = () => ({
  postcssPlugin: 'postcss-fa-font-urls',
  Declaration(decl) {
    if (decl.value.includes('url("../webfonts')) {
      decl.value = decl.value.replaceAll(regex, (value, filename) => `url("/${filename}")`);
    }
  },
});

faFontUrls.postcss = true;

export default faFontUrls;
