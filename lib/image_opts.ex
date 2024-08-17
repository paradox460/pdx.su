defmodule Pdx.ImageOpts do
  use Tableau.Extension, key: :image_opts, type: :pre_build, priority: 300

  def run(%{posts: posts} = token) do
    x = :global.trans(
    {:imageops, make_ref()},
    fn ->
      for %{body: body} = post <- posts do
          b2 = body
          |> Floki.parse_fragment!()
          |> Floki.traverse_and_update(fn
            {"img", attrs, children} ->
              attrs = attrs
              |> Enum.map(fn
                {"src", src} ->
                {"src", "/.netlify/images?url=" <> src}
                other -> other
              end)
              {"img", attrs, children}
            other -> other
          end)
          |> Floki.raw_html()

          %{post | body: b2}
        end
    end,
    [Node.self()],
    :infinity
    )

    {:ok, %{token | posts: x}}
  end
end

defmodule Pdx.ImageOpts.Config do
  def new(input), do: {:ok, input}
end
