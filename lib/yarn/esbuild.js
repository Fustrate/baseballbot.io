const { build } = require('esbuild');
const { sync: globSync } = require('glob');

const isProduction = process.env.NODE_ENV === 'production';

const options = {
  entryPoints: globSync('app/frontend/entrypoints/**/*.ts'),
  minify: isProduction,
  bundle: true,
  target: 'es6',
  outdir: 'app/assets/builds',
  sourcemap: isProduction,
  // logLevel: 'info',
};

build(options).catch((err) => {
  process.stderr.write(err.stderr);
  process.exit(1);
});
