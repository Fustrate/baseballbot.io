import metadata from './fa-vars-metadata.json' with { type: 'json' };

const regex = /fa-var\(([^)]+)\)/g;

const faVar = () => ({
  postcssPlugin: 'postcss-fa-var',
  Declaration(decl) {
    if (decl.value.includes('fa-var(')) {
      decl.value = decl.value.replaceAll(regex, (value, name) => {
        if (name in metadata.icons) {
          return `"\\${metadata.icons[name]}"`;
        }

        if (name in metadata.aliases) {
          throw new Error(`Font Awesome: ${name} is now ${metadata.aliases[name]}`);
        }

        throw new Error(`Font Awesome: ${name} is not a valid icon name.`);
      });
    }
  },
});

faVar.postcss = true;

export default faVar;
