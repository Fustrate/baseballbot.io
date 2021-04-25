// Based on Materialize CSS's Grid
// https://github.com/Dogfalo/materialize/blob/master/sass/components/_grid.scss

const gutterWidth = 1.2;

function columnClasses(size, columns) {
  const rules = [];

  for (let i = 1; i <= columns; i += 1) {
    const percent = `${100 / (columns / i)}%`;

    rules[`&.${size}-${i}`] = {
      left: 'auto',
      'margin-left': 'auto',
      right: 'auto',
      width: percent,
    };

    rules[`&.${size}-offset-${i}`] = {
      'margin-left': percent,
    };

    rules[`&.${size}-pull-${i}`] = {
      right: percent,
    };

    rules[`&.${size}-push-${i}`] = {
      left: percent,
    };

    rules[`&.${size}-centered`] = {
      float: 'none',
      'margin-left': 'auto',
      'margin-right': 'auto',
    };
  }

  return rules;
}

module.exports = (mixin, columns) => {
  const rules = {
    'margin-left': `${-gutterWidth / 2}rem`,
    'margin-right': `${-gutterWidth / 2}rem`,
    '&.collapse': {
      'margin-left': 0,
      'margin-right': 0,
      '.column, .columns': {
        padding: 0,
      },
    },
    // Clear floating children
    '&::after': {
      clear: 'both',
      content: '',
      display: 'table',
    },
    '.column, .columns': {
      'box-sizing': 'border-box',
      float: 'left',
      'min-height': '1px',
      padding: `0 ${gutterWidth / 2}rem`,
      '&[class*="push-"], &[class*="pull-"]': {
        position: 'relative',
      },
    },
  };

  Object.assign(rules['.column, .columns'], columnClasses('small', columns));

  rules['.column, .columns']['@media medium-up'] = columnClasses('medium', columns);
  rules['.column, .columns']['@media large-up'] = columnClasses('large', columns);
  rules['.column, .columns']['@media xlarge-up'] = columnClasses('xlarge', columns);

  return rules;
};
