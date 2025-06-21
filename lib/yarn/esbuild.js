import esbuild from 'esbuild';

// NODE_ENV doesn't seem to be set in production...
// const isProduction = process.env.NODE_ENV === 'production';
const watch = process.argv.includes('--watch');

const context = await esbuild.context({
  entryPoints: ['app/frontend/entrypoints/**/*.tsx'],
  bundle: true,
  target: 'es6',
  outdir: 'app/assets/builds',
  // plugins: [honeybadger],
  sourcemap: false,
  logLevel: watch ? 'info' : 'warning',
  define: {
    global: 'window',
  },
  minify: true,
  // Use ESM for code splitting
  format: 'esm',
  splitting: true,
  // Append '.digested' so that Propshaft doesn't add its own digest and lose the files
  chunkNames: '[name]-[hash].digested',
  treeShaking: true,
});

if (watch) {
  await context.watch();
} else {
  await context.rebuild();

  await context.dispose();

  // eslint-disable-next-line unicorn/no-process-exit
  process.exit(0);
}
