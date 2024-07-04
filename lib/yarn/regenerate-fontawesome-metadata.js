// There used to be a metadata file in node_modules/@fortawesome/fontawesome-pro, but now we need to generate our own.
// This is the only reason we install the fontawesome-pro package anymore.
import fs from 'node:fs';
import yaml from 'yaml';

const outputPath = './lib/postcss/fa-vars-metadata.json';

// We need to sort the data before dumping it to JSON so that git diffs aren't insane.
const sortObject = (original) => Object.fromEntries(Object.entries(original).sort());

const icons = {};
const aliases = {};

const data = yaml.parse(fs.readFileSync('./node_modules/@fortawesome/fontawesome-pro/metadata/icons.yml').toString());

for (const [name, { styles, unicode, aliases: aka }] of Object.entries(data)) {
  if (!styles.includes('solid')) {
    continue;
  }

  icons[name] = unicode;

  if (aka?.names) {
    for (const alias of aka.names) {
      aliases[alias] = name;
    }
  }
}

const { version } = JSON.parse(fs.readFileSync('./node_modules/@fortawesome/fontawesome-pro/package.json').toString());

fs.writeFileSync(outputPath, JSON.stringify({
  version,
  icons: sortObject(icons),
  aliases: sortObject(aliases),
}, undefined, 2));
