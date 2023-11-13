import * as esbuild from 'esbuild';
import {sassPlugin} from 'esbuild-sass-plugin';
import postcss from 'postcss';
import autoprefixer from 'autoprefixer';
import postcssPresetEnv from 'postcss-preset-env';
import { minifyHTMLLiteralsPlugin } from 'esbuild-plugin-minify-html-literals';

const dev = process.env.NODE_ENV !== "production";


export default await esbuild.context({
  entryPoints: ["./css/style.scss", "./js/index.ts"],
  bundle: true,
  minify: !dev,
  sourcemap: dev,
  legalComments: "linked",
  footer: {
    js: "/*! Copyright 2023 Jeff Sandberg */",
    css: "/* Copyright 2023 Jeff Sandberg */"
  },
  outdir: "../_site",
  plugins: [minifyHTMLLiteralsPlugin(), sassPlugin({
    async transform(source, resolveDir) {
      const {css} = await postcss([autoprefixer, postcssPresetEnv({stage: 0})]).process(source);
      return css
    }
  })]
});
