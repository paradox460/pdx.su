import Config

config :tableau, :reloader,
  patterns: [
    ~r"assets/.*\.(scss|js|ts)",
    ~r"lib/.*\.ex",
    ~r"(_posts|_pages)/.*.md"
  ]

config :tableau, :config,
  url: "http://localhost:4999",
  timezone: "America/Denver",
  markdown: [
    mdex: [
      extension: [
        autolink: true,
        footnotes: true,
        header_ids: "",
        strikethrough: true,
        superscript: true,
        table: true
      ],
      render: [unsafe_: true],
      features: [syntax_highlight_theme: "base16_tomorrow_night"]
    ]
  ]

config :tableau, :assets, yarn: ~w[--cwd assets watch]

config :temple, engine: EEx.SmartEngine, attributes: {Temple, :attributes}

config :tableau, Tableau.PostExtension,
  enabled: true,
  future: true,
  layout: "Pdx.PostLayout",
  permalink: "/blog/:file"

config :tableau, Tableau.PageExtension, enabled: true

config :tableau, Tableau.RSSExtension,
  enabled: true,
  title: "Jeff Sandberg's Blog",
  description: "The personal blog of Jeff Sandberg, software engineer"

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

import_config "#{Mix.env()}.exs"
