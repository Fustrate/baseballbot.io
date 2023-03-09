const esbuild = require('esbuild');
const { globSync } = require('glob');

// NODE_ENV doesn't seem to be set in production...
// const isProduction = process.env.NODE_ENV === 'production';
const watch = process.argv.includes('--watch');

(async () => {
  const context = await esbuild.context({
    entryPoints: globSync('app/frontend/entrypoints/**/*.ts'),
    bundle: true,
    target: 'es6',
    outdir: 'app/assets/builds',
    // Sourcemaps are including references to files in node_modules, and Honeybadger is trying to load them.
    sourcemap: false,
    logLevel: watch ? 'info' : 'warning',
    define: {
      global: 'window',
    },
    // Always minify until code splitting is more stable.
    minify: true,
    // Code splitting requires the ESM format
    // splitting: true,
    // format: 'esm',
  });

  if (watch) {
    await context.watch();
  } else {
    await context.rebuild();

    await context.dispose();

    process.exit(0);
  }
})();
