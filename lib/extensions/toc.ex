defmodule Pdx.Extensions.Toc do
  @moduledoc """
  Extracts a Table of Contents from each page, for use in the rendering step later
  """
  use Tableau.Extension, key: :toc, priority: 200

  @impl Tableau.Extension
  def pre_build(%{posts: posts} = token) do
    {:ok, %{token | posts: Enum.map(posts, &build_toc/1)}}
  end

  defp build_toc(%{notoc: true} = post), do: post

  defp build_toc(%{engine: engine, document: document} = post) do
    case Pdx.Converter.toc(engine, document) do
      [] -> Map.put(post, :notoc, true)
      toc -> Map.put(post, :toc, toc)
    end
  end

  defp build_toc(post), do: Map.put(post, :notoc, true)
end
