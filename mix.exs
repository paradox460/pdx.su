defmodule Pdx.MixProject do
  use Mix.Project

  def project do
    [
      app: :pdx,
      version: "0.1.0",
      elixir: "~> 1.16",
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
      {:carvex, "~> 0.0.1"},
      {:date_time_parser, "~> 1.3"},
      {:djot, "~> 1.0"},
      {:lumis, "~> 0.10"},
      {:lumis_wasm_bash, "~> 0.26"},
      {:lumis_wasm_comment, "~> 0.26"},
      {:lumis_wasm_css, "~> 0.26"},
      {:lumis_wasm_elixir, "~> 0.26"},
      {:lumis_wasm_fish, "~> 0.26"},
      {:lumis_wasm_heex, "~> 0.26"},
      {:lumis_wasm_html, "~> 0.26"},
      {:lumis_wasm_ini, "~> 0.26"},
      {:lumis_wasm_javascript, "~> 0.26"},
      {:lumis_wasm_json, "~> 0.26"},
      {:lumis_wasm_regex, "~> 0.26"},
      {:lumis_wasm_typescript, "~> 0.26"},
      {:lumis_wasm_vue, "~> 0.26"},
      {:lumis_wasm_yaml, "~> 0.26"},
      {:mdex, "~> 0.14"},
      {:phoenix_live_view, "~> 1.2"},
      {:tableau, "~> 0.31"},
      {:tableau_dev_server, "~> 0.1", only: :dev}
    ]
  end
end
