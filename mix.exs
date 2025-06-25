defmodule Pdx.MixProject do
  use Mix.Project

  def project do
    [
      app: :pdx,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:fe, "~> 0.1.5"},
      {:floki, "~> 0.38"},
      {:tableau, "~> 0.25"},
      {:date_time_parser, "~> 1.2"},
      {:mdex, "~> 0.7", override: true},
      {:rustler, ">= 0.0.0", optional: true},
      {:phoenix_live_view, "~> 1.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
