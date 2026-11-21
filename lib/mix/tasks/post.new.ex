defmodule Mix.Tasks.Post.New do
  @moduledoc """
  Generates a new blank post, with name and timestamp according to params.

  `mix post.new [opts] title`

  ## Options
  - `m`, `markdown` -- Use markdown instead of carve.
  - `j`, `djot` -- Use djot instead of carve.
  - `f`, `filename` -- File name to save post to, inside `_posts/`. Defaults to `yyyy-mm-dd-[transformed title]`. No extension is required
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
        strict: [
          filename: :string,
          date: :string,
          permalink: :string,
          markdown: :boolean,
          djot: :boolean
        ],
        aliases: [f: :filename, d: :date, p: :permalink, m: :markdown, j: :djot]
      )

    ext =
      cond do
        parsed[:markdown] && parsed[:djot] ->
          Mix.raise("--markdown and --djot are mutually exclusive")

        parsed[:markdown] ->
          "md"

        parsed[:djot] ->
          "dj"

        true ->
          "crv"
      end

    {:ok, config} = Tableau.Config.new(Map.new(Application.get_env(:tableau, :config, %{})))

    date =
      if parsed[:date] do
        parsed[:date]
        |> DateTime.from_iso8601()
        |> then(fn {:ok, date, _offset} -> date end)
        |> DateTime.shift_zone(config.timezone)
        |> then(fn {:ok, date} -> date end)
      else
        DateTime.now!(config.timezone)
      end

    front_date = DateTime.to_iso8601(date)

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

    filename = Path.join("_posts", post_filename(parsed[:filename], date, title, ext))

    post_template(frontmatter: frontmatter, title: title)
    |> then(&Mix.Generator.create_file(filename, &1))
  end

  defp maybe_put_permalink(frontmatter, parsed) do
    case Keyword.fetch(parsed, :permalink) do
      {:ok, permalink} -> Map.put(frontmatter, :permalink, permalink)
      :error -> frontmatter
    end
  end

  defp post_filename(nil, date, title, ext) do
    slug =
      title
      |> String.replace(~r/[^[:alnum:]]+/i, "-")
      |> String.downcase()

    post_filename("#{Calendar.strftime(date, "%Y-%m-%d")}-#{slug}", date, title, ext)
  end

  defp post_filename(filename, _date, _title, ext) do
    case Path.extname(filename) do
      "" -> "#{filename}.#{ext}"
      _ -> filename
    end
  end
end
