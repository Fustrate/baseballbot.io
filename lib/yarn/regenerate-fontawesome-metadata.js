// There used to be a metadata file in node_modules/@fortawesome/fontawesome-pro, but now we need to generate our own.
const fs = require('fs');
const yaml = require('js-yaml');

const metadataPath = './lib/postcss/fa-vars-metadata.yml';
const regex = /^\s+"([\da-z-]+)": \[\d+, \d+, \[([^\]]*)], "([^"]+)",/;

const icons = {};
const aliases = {};

// We need to sort the data before dumping it to YAML so that git diffs aren't insane.
function sortObject(original) {
  return Object.fromEntries(Object.entries(original).sort());
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
          .filter(([firstCharacter]) => firstCharacter === '"')
          .forEach((alias) => {
            aliases[alias.slice(1, -1)] = name;
          });
      }
    }
  });
}

loadIconsFromFile('light');
// loadIconsFromFile('brands');

fs.writeFileSync(metadataPath, yaml.dump({ icons: sortObject(icons), aliases: sortObject(aliases) }));
