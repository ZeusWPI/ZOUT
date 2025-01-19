// File adapted from https://hexdocs.pm/phoenix/asset_management.html#esbuild-plugins

import esbuild from 'esbuild';
import { sassPlugin } from 'esbuild-sass-plugin';

const args = process.argv.slice(2);
const watch = args.includes('--watch');
const deploy = args.includes('--deploy');

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
  '.ttf': 'file',
  '.otf': 'file',
  '.svg': 'file',
  '.eot': 'file',
  '.woff': 'file',
  '.woff2': 'file'
};

const plugins = [
  sassPlugin()
];

let opts = {
  entryPoints: ['js/app.js'],
  bundle: true,
  target: 'es2017',
  outdir: '../priv/static/assets',
  logLevel: 'info',
  loader,
  plugins
};

if (watch) {
  opts = {
    ...opts,
    sourcemap: 'inline'
  };
}

if (deploy) {
  opts = {
    ...opts,
    minify: true
  };
}

if (watch) {
  opts = {
    ...opts,
    sourcemap: "inline",
  };
  esbuild
    .context(opts)
    .then(async (ctx) => {
      await ctx.watch();
    })
    .catch((_error) => {
      process.exit(1);
    });
} else {
  await esbuild.build(opts);
}
