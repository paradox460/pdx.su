defmodule Pdx.Metadata do
  use Tableau.Extension, key: :metadata, type: :pre_build, priority: 500

  def run(%{posts: posts} = token) do
    :global.trans(
      {:metadata_extension, make_ref()},
      fn ->
        for %{body: body, file: file} = post <- posts, reduce: %{} do
          acc ->
            document = Floki.parse_fragment!(body)

            Map.put(acc, file, %{
              description: description(post, document),
              image: image(post, document)
            })
        end
        |> then(&Map.put(token, :metadata, &1))
        |> then(&{:ok, &1})
      end,
      [Node.self()],
      :infinity
    )
  end

  defp description(%{description: description}, _), do: description

  defp description(_post, document) do
    Floki.find(document, "p")
    |> Floki.text()
    |> String.trim()
    |> String.split(~r/([.?!])/, parts: 3, trim: true, include_captures: true)
    |> Enum.take(3)
    |> Enum.join("")
    |> then(&(&1 <> "…"))
  end

  defp image(%{image: image}, _document), do: image

  defp image(_post, document) do
    with src when not (src == []) <- Floki.attribute(document, "img", "src"),
         [image | _] <- src do
      Pdx.full_url(image)
    else
      _ -> nil
    end
  end
end

defmodule Pdx.Metadata.Config do
  def new(input), do: {:ok, input}
end
