defmodule Pdx.Extensions.Metadata do
  @moduledoc """
  Adds metadata to posts, for use in the `<head>` tag of the resulting HTML page.
  """

  use Tableau.Extension, key: :metadata, priority: 500

  @impl Tableau.Extension
  def pre_build(%{posts: posts} = token) do
    posts
    |> Enum.map(&build_metadata/1)
    |> then(&Map.put(token, :posts, &1))
    |> FE.Result.ok()
  end

  defp build_metadata(post) do
    doc =
      case post do
        %{mdex_document: doc} -> doc
        %{djot_document: doc} -> doc
      end

    Map.put(post, :metadata, %{
      description: description(post, doc),
      image: image(post, doc)
    })
  end

  defp description(%{description: description}, _), do: description

  defp description(_post, %MDEx.Document{} = doc) do
    case doc[:paragraph] do
      [paragraph | _] ->
        paragraph[:text]
        |> Enum.map_join("", & &1.literal)
        |> truncate_description()

      _ ->
        nil
    end
  end

  defp description(_post, [_] = doc) do
    doc
    |> Floki.find("p")
    |> hd()
    |> Floki.text()
    |> truncate_description()
  end

  defp image(%{image: image}, _document), do: image

  defp image(_post, %MDEx.Document{} = doc) do
    case doc[:image] do
      [image | _] -> Pdx.full_url(image.url)
      _ -> nil
    end
  end

  defp image(_post, [_] = doc) do
    with [img | _] <- Floki.find(doc, "img"),
         [src] <- Floki.attribute(img, "src") do
      Pdx.full_url(src)
    else
      _ -> nil
    end
  end

  defp truncate_description(text) do
    text
    |> String.split(~r/([.?!])/, parts: 3, trim: true, include_captures: true)
    |> Enum.take(3)
    |> Enum.join("")
    |> then(&(&1 <> "…"))
  end
end

defmodule Pdx.Metadata.Config do
  def new(input), do: {:ok, input}
end
