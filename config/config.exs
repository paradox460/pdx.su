import Config

config :tableau, :config,
  url: "http://localhost:4999",
  timezone: "America/Denver",
  markdown: [
    mdex: [
      extension: [header_ids: "", strikethrough: true],
      render: [unsafe_: true],
    ]
  ]

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
