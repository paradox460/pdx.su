import * as esbuild from "esbuild";
import { sassPlugin } from "esbuild-sass-plugin";
import postcss from "postcss";
import autoprefixer from "autoprefixer";
import postcssPresetEnv from "postcss-preset-env";
import { minifyHTMLLiteralsPlugin } from "esbuild-plugin-minify-html-literals";

const dev = process.env.NODE_ENV !== "production";

// Tableau automatically copies over the assets from the `/extra` directory, so
// anything that starts with `/extra/` should just be updated to match
let urlFixPlugin = {
  name: "url-fix",
  setup(build) {
    build.onResolve({ filter: /^\/extra\// }, (args) => {
      const fixedPath = args.path.replace(/^\/extra\//, "/");
      return {
        path: fixedPath,
        external: true,
      };
    });
  },
};

export default await esbuild.context({
  entryPoints: ["./css/style.scss", "./js/index.ts"],
  bundle: true,
  minify: !dev,
  sourcemap: dev,
  legalComments: "linked",
  footer: {
    js: "/*! Copyright 2025 Jeff Sandberg */",
    css: "/* Copyright 2025 Jeff Sandberg */",
  },
  outdir: "../_site",
  plugins: [
    minifyHTMLLiteralsPlugin(),
    urlFixPlugin,
    sassPlugin({
      async transform(source, _resolveDir, filePath) {
        const { css } = await postcss([
          autoprefixer,
          postcssPresetEnv({ stage: 0 }),
        ]).process(source, { from: filePath, to: "/css/style.css" });
        return css;
      },
    }),
  ],
});
