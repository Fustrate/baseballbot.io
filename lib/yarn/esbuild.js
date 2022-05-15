const { build } = require('esbuild');
const { sync } = require('glob');
const chokidar = require('chokidar');

// NODE_ENV doesn't seem to be set in production...
// const isProduction = process.env.NODE_ENV === 'production';
const watch = process.argv.includes('--watch');

const options = {
  entryPoints: sync('app/frontend/entrypoints/**/*.ts'),
  bundle: true,
  target: 'es6',
  outdir: 'app/assets/builds',
  // Sourcemaps are including references to files in node_modules, and Honeybadger is trying to load them.
  sourcemap: false,
  logLevel: watch ? 'info' : 'warning',
  watch,
  incremental: watch,
  define: {
    global: 'window',
  },
  // Always minify until code splitting is more stable.
  minify: true,
  // Code splitting requires the ESM format
  // splitting: true,
  // format: 'esm',
};

if (watch) {
  (async () => {
    const result = await build(options);

    chokidar.watch(['./yarn.lock']).on('change', (path) => {
      process.stdout.write(`[watch] build started (change: "${path}")\n`);

      result.rebuild();

      process.stdout.write('[watch] build finished\n');
    });
  })();
} else {
  build(options).catch((error) => {
    process.stdout.write(JSON.stringify(error));

    process.exit(1);
  });
}
