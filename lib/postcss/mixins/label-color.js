const Color = require('color');

module.exports = (mixin, backgroundColor, borderColor = false) => {
  const bgColor = Color(backgroundColor);

  const rules = {
    'background-color': bgColor.toString(),
  };

  if (bgColor.isDark()) {
    rules.color = '$label-font-color-alt';
    rules['text-shadow'] = `0 1px 1px ${bgColor.darken(0.7).toString()}`;
  } else {
    rules.color = '$label-font-color';
    rules['text-shadow'] = `0 1px 1px ${bgColor.lighten(0.7).toString()}`;
  }

  if (borderColor) {
    rules.border = `1px solid ${borderColor}`;
  }

  return rules;
};
