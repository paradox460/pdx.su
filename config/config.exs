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
  converters: [
    md: Pdx.Converters.MDExConverter
  ],
  markdown: [
    mdex: [
      extension: [
        alerts: true,
        autolink: true,
        description_lists: true,
        footnotes: true,
        header_ids: "",
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
      syntax_highlight: [
        formatter: :html_linked
      ]
    ]
  ]

config :tableau, :assets, yarn: ~w[--cwd assets watch]

config :tableau, Tableau.PostExtension,
  enabled: true,
  future: true,
  layout: "Pdx.PostLayout",
  permalink: "/blog/:year-:month-:day-:title"

config :tableau, Pdx.Extensions.Toc, enabled: true

config :tableau, Tableau.PageExtension, enabled: true

config :tableau, Tableau.RSSExtension,
  enabled: true,
  title: "Jeff Sandberg's Blog",
  description: "The personal blog of Jeff Sandberg, software engineer"

config :tableau, Tableau.SitemapExtension, enabled: true

config :tableau, Pdx.Extensions.Metadata, enabled: true

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

import_config "#{Mix.env()}.exs"
