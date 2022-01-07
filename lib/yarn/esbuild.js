const { build } = require('esbuild');
const { sync: globSync } = require('glob');

const isProduction = process.env.NODE_ENV === 'production';

const watch = JSON.parse(process.env.npm_config_argv).original.some((arg) => arg === '--watch');

const options = {
  entryPoints: globSync('app/frontend/entrypoints/**/*.ts'),
  minify: isProduction,
  bundle: true,
  target: 'es6',
  outdir: 'app/assets/builds',
  sourcemap: isProduction,
  logLevel: isProduction ? 'warning' : 'info',
  watch: !isProduction && watch,
};

build(options).catch((err) => {
  process.stderr.write(err.stderr);
  process.exit(1);
});
