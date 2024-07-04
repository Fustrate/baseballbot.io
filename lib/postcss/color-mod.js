import Color from 'color';

const regex = /color-mod\((#[\da-f]+|rgb\((?:\d+,\s*){2}\d+\))\s+((?:(?:lightness|shade|tint|alpha|saturation)\(-?\d+%\)\s*)+)\)/gi;

function transformColor(color, transform) {
  const [name, number] = transform.slice(0, -2).split('(', 2);
  const amount = Number(number);

  switch (name) {
    case 'lightness': {
      return color.lightness(amount);
    }
    case 'saturation': {
      return color.saturationl(amount);
    }
    case 'alpha': {
      return color.alpha(amount / 100);
    }
    default: {
      return color;
    }
  }
}

const colorMod = () => ({
  postcssPlugin: 'postcss-color-mod',
  Declaration(decl) {
    if (decl.value.includes('color-mod(')) {
      decl.value = decl.value.replaceAll(regex, (value, original, functions) => {
        let color = Color(original);

        for (const transform of functions.trim().split(' ')) {
          color = transformColor(color, transform);
        }

        return color.hsl().string();
      });
    }
  },
});

colorMod.postcss = true;

export default colorMod;
