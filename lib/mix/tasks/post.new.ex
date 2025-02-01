defmodule Mix.Tasks.Post.New do
  @moduledoc """
  Generates a new blank post, with name and timestamp according to params.

  `mix post.new [opts] title`

  ## Options
  - `f`, `filename` -- File name to save post to. Defaults to `yyyy-mm-dd-[transformed title]`. No extension is required
  - `d`, `date` -- Date for post. If absent, defaults to "now"
  - `p`, `permalink` -- Permalink for post frontmatter. If absent, will be up to application configuration
  """

  @shortdoc "Generates a new post. `mix post.new [opts] title`"

  use Mix.Task
  require Mix.Generator

  Mix.Generator.embed_template("post", """
  <%= @frontmatter %>
  # <%= @title %>

  """)

  @impl Mix.Task
  def run(argv) do
    {parsed, args} =
      OptionParser.parse!(argv,
        strict: [filename: :string, date: :string, permalink: :string],
        aliases: [f: :filename, d: :date, p: :permalink]
      )

    {:ok, config} = Tableau.Config.new(Map.new(Application.get_env(:tableau, :config, %{})))

    date =
      if parsed[:date] do
        parsed.date
        |> DateTime.from_iso8601()
        |> then(fn {:ok, date, _offset} -> date end)
        |> DateTime.shift_zone("America/Denver")
        |> then(fn {:ok, date} -> date end)
      else
        DateTime.now!(config.timezone)
      end

    front_date =
      date
      |> DateTime.to_iso8601()
      |> then(&"#{&1}")

    title = Enum.join(args, " ")

    frontmatter =
      %{date: front_date, title: title}
      |> maybe_put_permalink(parsed)
      |> Enum.map_join("\n", fn {key, value} ->
        "#{key}: #{value}"
      end)
      |> then(fn frontmatter_block ->
        """
        ---
        #{frontmatter_block}
        ---
        """
      end)

    title = Enum.join(args, " ")

    filename =
      parsed[:filename] ||
        gen_filename(date, title)
        |> then(&Path.join("_posts/", &1))

    post_template(frontmatter: frontmatter, title: title)
    |> then(&Mix.Generator.create_file(filename, &1))
  end

  defp maybe_put_permalink(frontmatter, %{permalink: permalink}) do
    Map.put(frontmatter, :permalink, permalink)
  end

  defp maybe_put_permalink(frontmatter, _), do: frontmatter

  defp gen_filename(date, title) do
    filename =
      title
      |> String.replace(~r/[^[:alnum:]]+/i, "-")
      |> String.downcase()

    output_date = Calendar.strftime(date, "%Y-%m-%d")

    "#{output_date}-#{filename}.md"
  end
end
