import Config

config :mdex_native, syntax_highlighter: :lumis

config :tableau, :reloader,
  patterns: [
    ~r"assets/.*\.(scss|js|ts)",
    ~r"lib/.*\.ex",
    ~r"(_posts|_pages)/.*\.(md|dj)"
  ]

config :tableau, :config,
  url: "http://localhost:4999",
  timezone: "America/Denver",
  converters: [
    dj: Pdx.Converters.DjotConverter,
    md: Pdx.Converters.MDExConverter
  ]

syntax_highlight = [engine: :lumis, opts: [formatter: :html_linked]]

config :tableau, Pdx.Converters.MDExConverter,
  extension: [
    alerts: true,
    autolink: true,
    description_lists: true,
    footnotes: true,
    header_id_prefix: "",
    math_dollars: true,
    multiline_block_quotes: true,
    strikethrough: true,
    subscript: true,
    superscript: true,
    table: true,
    tasklist: true,
    underline: true
  ],
  render: [unsafe: true],
  syntax_highlight: syntax_highlight

config :tableau, Pdx.Converters.DjotConverter, syntax_highlight: syntax_highlight

config :tableau, :assets, bun: ~w[--cwd assets watch]

config :tableau, Tableau.PostExtension,
  enabled: true,
  future: true,
  layout: "Pdx.PostLayout",
  permalink: "/blog/:year-:month-:day-:title"

config :tableau, Tableau.PageExtension, enabled: true

config :tableau, Tableau.RSSExtension,
  enabled: true,
  title: "Jeff Sandberg's Blog",
  description: "The personal blog of Jeff Sandberg, software engineer"

config :tableau, Tableau.SitemapExtension, enabled: true

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

import_config "#{Mix.env()}.exs"
