const sizes = {
  small: 48,
  medium: 80,
  large: 100,
  xlarge: Number.POSITIVE_INFINITY,
};

let previousLimit;

const mediaValues = {
  screen: 'only screen',
  landscape: 'only screen and (orientation: landscape)',
  portrait: 'only screen and (orientation: portrait)',
};

for (const [name, limit] of Object.entries(sizes)) {
  if (previousLimit) {
    mediaValues[`${name}-up`] = `only screen and (min-width: ${previousLimit + 0.063}em)`;

    // On the last size, there's no upper limit
    mediaValues[`${name}-only`] = limit === Number.POSITIVE_INFINITY
      ? mediaValues[`${name}-up`]
      : `only screen and (min-width: ${previousLimit + 0.063}em) and (max-width: ${limit}em)`;
  } else {
    mediaValues[`${name}-up`] = 'only screen';
    mediaValues[`${name}-only`] = `only screen and (max-width: ${limit}em)`;
  }

  previousLimit = limit;
}

const customRegex = /^(?<operator>[<>]=?)\s*(?<amount>\d+(?:\.\d+)?)r?em$/;

function parseCustomRule(params) {
  const match = params.match(customRegex);

  if (!match) {
    return params;
  }

  switch (match.groups.operator) {
    case '>': {
      return `only screen and (min-width: ${match.groups.amount + 0.063}em)`;
    }
    case '>=': {
      return `only screen and (min-width: ${match.groups.amount}em)`;
    }
    case '<': {
      return `only screen and (max-width: ${match.groups.amount - 0.063}em)`;
    }
    case '<=': {
      return `only screen and (max-width: ${match.groups.amount}em)`;
    }
    default: {
      return params;
    }
  }
}

const media = () => ({
  postcssPlugin: 'postcss-media',
  AtRule: {
    media: (rule) => {
      if (mediaValues[rule.params]) {
        rule.replaceWith(rule.clone({ params: mediaValues[rule.params] }));
      } else if (customRegex.test(rule.params)) {
        rule.replaceWith(rule.clone({ params: parseCustomRule(rule.params) }));
      }
    },
  },
});

media.postcss = true;

export default media;
