// There used to be a metadata file in node_modules/@fortawesome/fontawesome-pro, but now we need to generate our own.
const fs = require('node:fs');
const yaml = require('js-yaml');

const metadataPath = './lib/postcss/fa-vars-metadata.json';

const icons = {};
const aliases = {};

// We need to sort the data before dumping it to JSON so that git diffs aren't insane.
function sortObject(original) {
  return Object.fromEntries(Object.entries(original).sort());
}

const data = fs.readFileSync('./node_modules/@fortawesome/fontawesome-pro/metadata/icons.yml').toString();

const yamlData = yaml.load(data);

Object.entries(yamlData).forEach(([name, info]) => {
  if (!info.styles.includes('regular')) {
    return;
  }

  icons[name] = info.unicode;

  if (info.aliases?.names) {
    info.aliases.names.forEach((alias) => {
      aliases[alias] = name;
    });
  }
});

// fs.writeFileSync('./app/frontend/icons.d.ts', `type FontAwesomeIcon = '${Object.keys(icons).sort().join("' | '")}';
// `);
fs.writeFileSync(metadataPath, JSON.stringify({ icons: sortObject(icons), aliases: sortObject(aliases) }, null, 2));
