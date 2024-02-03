defmodule Pdx.Toc do
  use Tableau.Extension, key: :toc, type: :pre_build, priority: 200

  def run(%{posts: posts} = token) do
    :global.trans(
      {:toc_extension, make_ref()},
      fn ->
        tocs =
          for %{body: body, file: file} = post <- posts, !post[:notoc], reduce: %{} do
            acc ->
              toc =
                Floki.parse_fragment!(body)
                |> Floki.find("h2, h3, h4")
                |> Enum.map(fn {type, _, _} = node ->
                  depth =
                    case type do
                      "h2" -> 1
                      "h3" -> 2
                      "h4" -> 3
                    end

                  text = Floki.text(node)
                  [id | _] = Floki.attribute(node, "a", "id")

                  %{text: text, id: id, depth: depth}
                end)

              acc
              |> Map.put(file, toc)
          end

        token
        |> Map.put(:toc, tocs)
        |> then(&{:ok, &1})
      end,
      [Node.self()],
      :infinity
    )
  end
end

defmodule Pdx.Toc.Config do
  def new(input), do: {:ok, input}
end
