// There used to be a metadata file in node_modules/@fortawesome/fontawesome-pro, but now we need to generate our own.
const fs = require('fs');
const yaml = require('js-yaml');

const metadataPath = './lib/postcss/fa-vars-metadata.yml';
const regex = /^\s+"([a-z0-9-]+)": \[\d+, \d+, \[([^\]]*)\], "([^"]+)",/;

const icons = {};
const aliases = {};

// We need to sort the data before dumping it to YAML so that git diffs aren't insane.
function sortObject(original) {
  return Object.keys(original).sort().reduce(
    (obj, key) => {
      obj[key] = original[key];
      return obj;
    },
    {},
  );
}

function loadIconsFromFile(filename) {
  const data = fs.readFileSync(`./node_modules/@fortawesome/fontawesome-pro/js/${filename}.js`).toString();

  data.split('\n').forEach((line) => {
    const matches = regex.exec(line);

    if (matches) {
      const [, name, rawAliases, unicode] = matches;

      icons[name] = unicode;

      if (rawAliases) {
        rawAliases
          .split(', ')
          .filter((alias) => alias[0] === '"')
          .forEach((alias) => {
            aliases[alias.substring(1, alias.length - 1)] = name;
          });
      }
    }
  });
}

loadIconsFromFile('light');
// loadIconsFromFile('brands');

fs.writeFileSync(metadataPath, yaml.dump({ icons: sortObject(icons), aliases: sortObject(aliases) }));
