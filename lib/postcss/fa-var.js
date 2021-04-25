const fs = require('fs');
const yaml = require('js-yaml');

const metadataPath = './node_modules/@fortawesome/fontawesome-pro/metadata/icons.yml';

const unicode = {};
const metadata = yaml.load(fs.readFileSync(metadataPath, 'utf8'));

const regex = /fa-var\(([^)]+)\)/g;

Object.keys(metadata).forEach((key) => {
  unicode[key] = metadata[key].unicode;
});

module.exports = () => ({
  postcssPlugin: 'postcss-fa-var',
  Declaration(decl) {
    if (regex.test(decl.value)) {
      decl.value = decl.value.replace(regex, (value, name) => `"\\${unicode[name]}"`);
    }
  },
});

module.exports.postcss = true;
