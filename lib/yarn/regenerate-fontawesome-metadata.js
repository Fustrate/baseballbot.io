// There used to be a metadata file in node_modules/@fortawesome/fontawesome-pro, but now we need to generate our own.
const fs = require('node:fs');
const yaml = require('yaml');

const outputPath = './lib/postcss/fa-vars-metadata.json';

const icons = {};
const aliases = {};

const data = fs.readFileSync('./node_modules/@fortawesome/fontawesome-pro/metadata/icons.yml').toString();

Object.entries(yaml.parse(data)).forEach(([name, { styles, unicode, aliases: aka }]) => {
  if (!styles.includes('solid')) {
    return;
  }

  icons[name] = unicode;

  aka?.names?.forEach((alias) => {
    aliases[alias] = name;
  });
});

// We need to sort the data before dumping it to JSON so that git diffs aren't insane.
const sortObject = (original) => Object.fromEntries(Object.entries(original).sort());

fs.writeFileSync(outputPath, JSON.stringify({ icons: sortObject(icons), aliases: sortObject(aliases) }, null, 2));
