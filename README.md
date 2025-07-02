This is the repository of my personal website, https://pdx.su.

The site is built using [tableau](https://github.com/elixir-tools/tableau), an elixir powered static site generator. Templates are written using Phoenix LiveView HEEx templates. CSS is processed with Sass, for legacy reasons, but should be written as if it was plain, modern, indented CSS. All JS is written in TypeScript, and where componentization is needed, it uses [Lit](https://lit.dev/). Asset bundling is done via Esbuild running on Bun.

Posts can be written in Markdown or [Djot](https://djot.net/), indicated by their file extension.

Deployments are handled via Github Actions, and the resulting output is hosted on Netlify.

Source code is licensed under MIT license, while all text prose (`_posts/*`, `_pages/*`, and any other similar content) is Copyright (c) its respective dates to Jeff Sandberg (me).
