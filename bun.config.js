import fs from 'node:fs';
import path from 'node:path';

import { TanStackRouterCodeSplitterEsbuild } from '@tanstack/router-plugin/esbuild';

const config = {
  entrypoints: ['app/frontend/entrypoints/application.tsx'],
  outdir: 'app/assets/builds',
  minify: true,
  sourcemap: 'none',
  target: 'browser',
  splitting: true,
  naming: {
    // Append '.digested' so that Propshaft doesn't add its own digest and lose the files
    entry: '[dir]/[name].[ext]',
    chunk: '[name]-[hash].digested.[ext]',
    asset: '[name]-[hash].digested.[ext]',
  },
  plugins: [
    TanStackRouterCodeSplitterEsbuild({
      target: 'react',
      autoCodeSplitting: true,
      routesDirectory: './app/frontend/routes',
      generatedRouteTree: './app/frontend/routeTree.gen.ts',
    }),
  ],
  define: {
    global: 'window',
  },
};

const build = async (config) => {
  const result = await Bun.build(config);

  if (!result.success) {
    if (process.argv.includes('--watch')) {
      console.error("Build failed");

      for (const message of result.logs) {
        console.error(message);
      }

      return;
    }

    throw new AggregateError(result.logs, "Build failed");
  }
};

(async () => {
  await build(config);

  if (process.argv.includes('--watch')) {
    fs.watch(path.join(process.cwd(), "app/frontend"), { recursive: true }, (_eventType, filename) => {
      if (filename.endsWith('.ts') || filename.endsWith('.tsx')) {
        console.log(`File changed: ${filename}. Rebuilding...`);
        build(config);
      }
    });
  } else {
    process.exit(0);
  }
})();
