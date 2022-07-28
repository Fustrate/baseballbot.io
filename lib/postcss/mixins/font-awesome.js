const extras = {
  solid: { 'font-weight': 900 },
  light: { 'font-weight': 300 },
  regular: { 'font-weight': 400 },
  brands: { 'font-weight': 400, 'font-family': '"Font Awesome 6 Brands"' },
  thin: { 'font-weight': 100 },
  'full-width': {
    display: 'inline-block',
    'text-align': 'center',
    width: '1.25em',
  },
  spin: {
    '-webkit-animation': 'fa-spin 2s infinite linear',
    animation: 'fa-spin 2s infinite linear',
    display: 'inline-block',
  },
};

module.exports = (mixin, style) => {
  const rules = {
    '-moz-osx-font-smoothing': 'grayscale',
    '-webkit-font-smoothing': 'antialiased',
    'font-family': '"Font Awesome 6 Pro"',
    'text-rendering': 'auto',
    display: 'inline-block',
    'font-style': 'normal',
    'font-variant': 'normal',
    'line-height': '1',
  };

  style?.split(' ')?.forEach((option) => {
    if (extras[option]) {
      Object.assign(rules, extras[option]);
    }
  });

  return rules;
};
