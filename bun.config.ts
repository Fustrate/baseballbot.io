import fs from 'node:fs';
import path from 'node:path';
import Bun from 'bun';

// Tanstack's code splitting doesn't work with Bun yet - it looks like unplugin v3 is still in beta, after which
// @tanstack/router-plugin will need to be updated to support v3 and Bun.
const config: Bun.BuildConfig = {
  entrypoints: ['app/frontend/entrypoints/application.tsx'],
  outdir: 'app/assets/builds',
  minify: true,
  splitting: true,
  naming: {
    // Append '.digested' so that Propshaft doesn't add its own digest and lose the files
    entry: '[dir]/[name].[ext]',
    chunk: 'chunk-[hash].digested.[ext]',
    asset: '[name]-[hash].digested.[ext]',
  },
  // define: {
  //   global: 'window',
  // },
};

const build = async (config: Bun.BuildConfig) => {
  const result = await Bun.build(config);

  if (!result.success) {
    if (process.argv.includes('--watch')) {
      console.error('Build failed');

      for (const message of result.logs) {
        console.error(message);
      }

      return;
    }

    throw new AggregateError(result.logs, 'Build failed');
  }
};

(async () => {
  await build(config);

  if (process.argv.includes('--watch')) {
    fs.watch(path.join(process.cwd(), 'app/frontend'), { recursive: true }, (_eventType, filename) => {
      if (filename.endsWith('.ts') || filename.endsWith('.tsx')) {
        console.log(`File changed: ${filename}. Rebuilding...`);
        build(config);
      }
    });
  } else {
    process.exit(0);
  }
})();
