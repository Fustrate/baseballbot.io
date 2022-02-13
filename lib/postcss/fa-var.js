const { icons, aliases } = require('./fa-vars-metadata.json');

const regex = /fa-var\(([^)]+)\)/g;

module.exports = () => ({
  postcssPlugin: 'postcss-fa-var',
  Declaration(decl) {
    if (decl.value.includes('fa-var(')) {
      decl.value = decl.value.replace(regex, (value, name) => {
        if (name in icons) {
          return `"\\${icons[name]}"`;
        }

        if (name in aliases) {
          throw new Error(`Font Awesome: ${name} is now ${aliases[name]}`);
        }

        throw new Error(`Font Awesome: ${name} is not a valid icon name.`);
      });
    }
  },
});

module.exports.postcss = true;
