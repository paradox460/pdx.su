import * as esbuild from 'esbuild';
import {sassPlugin} from 'esbuild-sass-plugin';
import postcss from 'postcss';
import autoprefixer from 'autoprefixer';
import postcssPresetEnv from 'postcss-preset-env';


export default await esbuild.context({
  entryPoints: ["./css/style.scss", "./js/index.ts"],
  bundle: true,
  sourcemap: true,
  outdir: "../_site",
  plugins: [sassPlugin({
    async transform(source, resolveDir) {
      const {css} = await postcss([autoprefixer, postcssPresetEnv({stage: 0})]).process(source);
      return css
    }
  })]
});
