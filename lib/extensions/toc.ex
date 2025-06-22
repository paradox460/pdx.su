defmodule Pdx.Extensions.Toc do
  @moduledoc """
  Extracts a Table of Contents from each page, for use in the rendering step later
  """
  use Tableau.Extension, key: :toc, priority: 200

  @impl Tableau.Extension
  # TODO: add prebuild that skips notoc pages
  def pre_build(%{posts: posts} = token) do
    for post <- posts do
      doc = Pdx.Converters.MDExConverter.to_ast(post.body)

      selector = fn
        %MDEx.Heading{level: level} when level in 2..4 -> true
        _ -> false
      end

      for heading <- List.wrap(doc[selector]), reduce: %{toc_ids: %{}, toc: []} do
        %{toc_ids: toc_ids, toc: toc} = acc ->
          with [text | _] <- heading[:text],
               text when not is_nil(text) <- text.literal,
               {id, toc_id_count} <- make_id(text, toc_ids),
               level <- heading.level do
            %{
              acc
              | toc: [%{text: text, id: id, depth: level} | toc],
                toc_ids: Map.put(toc_ids, id, toc_id_count)
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
    |> then(&Map.put(token, :posts, &1))
    |> FE.Result.ok()
  end

  defp make_id(text, toc_ids) do
    text
    |> String.replace(~r/[^ |\-|\p{Mc}|\p{Me}|\p{Mn}|\p{Pc}|[[:alnum:]]/u, "")
    |> String.downcase()
    |> String.replace(~r/ /, "-")
    |> then(fn
      id ->
        case Map.get(toc_ids, id, 0) do
          0 -> {id, 1}
          count -> {"#{id}-#{count}", count + 1}
        end
    end)
  end
end

defmodule Pdx.Toc.Config do
  def new(input), do: {:ok, input}
end
