defmodule Pdx.Extensions.Metadata do
  @moduledoc """
  Adds metadata to posts, for use in the `<head>` tag of the resulting HTML page.
  """

  use Tableau.Extension, key: :metadata, priority: 500

  @impl Tableau.Extension
  def pre_build(%{posts: posts} = token) do
    {:ok, %{token | posts: Enum.map(posts, &build_metadata/1)}}
  end

  defp build_metadata(%{engine: engine, document: document} = post) do
    Map.put(post, :metadata, %{
      description: description(post, engine, document),
      image: image(post, document)
    })
  end

  defp build_metadata(post), do: post

  defp description(%{description: description}, _engine, _document), do: description

  defp description(_post, engine, document) do
    case document[:paragraph] do
      [paragraph | _] -> engine |> Pdx.Converter.text(paragraph) |> truncate_description()
      _ -> nil
    end
  end

  defp image(%{image: image}, _document), do: image

  defp image(_post, document) do
    case document[:image] do
      [image | _] -> Pdx.full_url(image.url)
      _ -> nil
    end
  end

  @description_sentences 2

  defp truncate_description(text) do
    # A sentence ends at `.`, `?` or `!` followed by whitespace and something that can start a
    # sentence, so abbreviations such as "e.g. this" and numbers such as "1.5" don't split.
    sentence_boundary = ~r/(?<=[.?!])\s+(?=[\p{Lu}\p{N}"“‘'(\[])/u

    case String.split(text, sentence_boundary, parts: @description_sentences + 1) do
      sentences when length(sentences) > @description_sentences ->
        sentences
        |> Enum.take(@description_sentences)
        |> Enum.join(" ")
        |> String.trim_trailing(".")
        |> Kernel.<>("…")

      _ ->
        text
    end
  end
end
