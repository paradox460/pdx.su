defmodule Pdx.Extensions.Toc do
  @moduledoc """
  Extracts a Table of Contents from each page, for use in the rendering step later
  """
  use Tableau.Extension, key: :toc, priority: 200

  @impl Tableau.Extension
  def pre_build(%{posts: posts} = token) do
    posts
    |> Enum.map(&build_toc/1)
    |> then(&Map.put(token, :posts, &1))
    |> FE.Result.ok()
  end

  defp build_toc(%{notoc: true} = post), do: post

  defp build_toc(%{mdex_document: doc} = post) do
    selector = fn
      %MDEx.Heading{level: level} when level in 2..4 -> true
      _ -> false
    end

    for heading <- List.wrap(doc[selector]), reduce: %{toc_ids: %{}, toc: []} do
      %{toc_ids: toc_ids, toc: toc} = acc ->
        with [text | _] <- heading[:text],
             text when not is_nil(text) <- text.literal,
             {id, toc_id_cat, toc_id_count} <- make_id(text, toc_ids),
             level <- heading.level do
          %{
            acc
            | toc: [%{text: text, id: id, depth: level} | toc],
              toc_ids: Map.put(toc_ids, toc_id_cat, toc_id_count)
          }
        else
          _ -> acc
        end
    end
    |> then(fn
      %{toc: toc} when toc != [] ->
        Map.put(post, :toc, Enum.reverse(toc))

      _ ->
        post
    end)
  end

  @heading_levels %{
    "h2" => 2,
    "h3" => 3,
    "h4" => 4
  }
  @headings @heading_levels |> Map.keys()

  defp build_toc(%{djot_document: doc} = post) do
    doc
    |> Floki.find("section")
    |> Enum.flat_map(fn {_tag, _attr, children} = section ->
      heading =
        Enum.find(children, fn
          {tag, _attr, _children} when tag in @headings -> true
          _ -> false
        end)

      if heading != nil do
        {tag, _, _} = heading

        [
          %{
            text: Floki.text(heading),
            id: Floki.attribute(section, "id") |> hd,
            depth: @heading_levels[tag]
          }
        ]
      else
        []
      end
    end)
    |> then(fn
      toc when toc != [] ->
        Map.put(post, :toc, toc)

      _ ->
        post
    end)
  end

  defp build_toc(post) do
    Map.put(post, :notoc, true)
  end

  defp make_id(text, toc_ids) do
    text
    |> MDEx.anchorize()
    |> then(fn
      id ->
        case Map.get(toc_ids, id, 0) do
          0 -> {id, id, 1}
          count -> {"#{id}-#{count}", id, count + 1}
        end
    end)
  end
end

defmodule Pdx.Toc.Config do
  def new(input), do: {:ok, input}
end
