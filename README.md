# pdx.su

Personal blog of Jeff Sandberg — software engineer.

https://pdx.su

## Stack

| Layer | Technology |
|-------|-----------|
| SSG | [Tableau](https://github.com/elixir-tools/tableau) (Elixir) |
| Templates | Phoenix LiveView HEEx |
| CSS | Sass (Esbuild via Bun) |
| JS | TypeScript + [Lit](https://lit.dev/) web components |
| Markdown | [MDEx](https://github.com/elixir-tools/mdex) (CommonMark + extensions) |
| Djot | [Djot](https://djot.net/) + [Autumn](https://github.com/RobertDober/autumn) for syntax highlighting |
| Deployment | GitHub Actions → Netlify |
| Hooks | [hk](https://github.com/jdx/hk) |

## Writing posts

Posts live in `_posts/` and are written in either Markdown (`.md`) or Djot (`.dj`). Front matter is YAML.

Supported Markdown extensions: alerts, autolink, description lists, footnotes, math, strikethrough, subscript/superscript, tables, task lists, underline.

Djot posts get syntax highlighting via Autumn, with line-level highlight annotations via `highlight` attributes on code blocks.

## Development

### Prerequisites

- Elixir 1.15+
- Bun (for asset building)

### Getting started

```bash
mix deps.get
bun install
mix tableau.server
```

The reloader watches `assets/`, `lib/`, `_posts/`, and `_pages/` for changes.

### Asset pipeline

Sass compiles to CSS; TypeScript compiles via Esbuild. Both run through Bun.

```bash
bun install
```

The asset watcher starts automatically alongside `mix tableau.server` (configured in `config.exs`).

### Pre-commit hooks

```bash
hk check    # run all checks
hk fix      # auto-fix where possible (formatting)
```

Checks include: Elixir compilation, formatting, Pkl validation, and Prettier.

### Creating posts

```bash
mix post.new "Post title"          # defaults to Djot
mix post.new --markdown "Title"    # Markdown
mix post.new --filename my-post "Title"
mix post.new --date 2026-01-01 "Title"
```

## License

Source code: MIT.

Text content (`_posts/`, `_pages/`, etc.): Copyright (c) each post's date by Jeff Sandberg.
