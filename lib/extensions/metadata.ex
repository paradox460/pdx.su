defmodule Pdx.Extensions.Metadata do
  @moduledoc """
  Adds metadata to posts, for use in the `<head>` tag of the resulting HTML page.
  """

  use Tableau.Extension, key: :metadata, priority: 500

  @impl Tableau.Extension
  def pre_build(%{posts: posts} = token) do
    for post <- posts do
      doc = Pdx.Converters.MDExConverter.to_ast(post.body)

      Map.put(post, :metadata, %{
        description: description(post, doc),
        image: image(post, doc)
      })
    end
    |> then(&Map.put(token, :posts, &1))
    |> FE.Result.ok()
  end

  defp description(%{description: description}, _), do: description

  defp description(_post, doc) do
    case doc[:paragraph] do
      [paragraph | _] ->
        paragraph[:text]
        |> Enum.map_join("", & &1.literal)
        |> String.trim()
        |> String.split(~r/([.?!])/, parts: 3, trim: true, include_captures: true)
        |> Enum.take(3)
        |> Enum.join("")
        |> then(&(&1 <> "…"))

      _ ->
        nil
    end
  end

  defp image(%{image: image}, _document), do: image

  defp image(_post, doc) do
    case doc[:image] do
      [image | _] -> Pdx.full_url(image.url)
      _ -> nil
    end
  end
end

defmodule Pdx.Metadata.Config do
  def new(input), do: {:ok, input}
end
