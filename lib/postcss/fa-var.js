const fs = require('fs');
const yaml = require('js-yaml');

const metadataPath = './lib/postcss/fa-vars-metadata.yml';

const icons = {};
const unicodeAliases = {};
const metadata = yaml.load(fs.readFileSync(metadataPath, 'utf8'));

const regex = /fa-var\(([^)]+)\)/g;

Object.keys(metadata).forEach((key) => {
  icons[key] = metadata[key].unicode;

  // Font Awesome 6 changed a lot of names around
  metadata[key].aliases?.names?.forEach((alias) => { unicodeAliases[alias] = key; });
});

module.exports = () => ({
  postcssPlugin: 'postcss-fa-var',
  Declaration(decl) {
    if (regex.test(decl.value)) {
      decl.value = decl.value.replace(regex, (value, name) => {
        if (!icons[name]) {
          if (name in unicodeAliases) {
            throw new Error(`Font Awesome: ${name} is now ${unicodeAliases[name]}`);
          } else {
            throw new Error(`Font Awesome: ${name} is not a valid icon name.`);
          }
        }

        return `"\\${icons[name]}"`;
      });
    }
  },
});

module.exports.postcss = true;
