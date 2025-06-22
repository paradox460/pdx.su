defmodule Pdx.Extensions.MDExDocument do
  @moduledoc """
  Stores the current posts "document" in the token, so other extensions don't have to regen it
  """

  use Tableau.Extension, key: :mdex_document, priority: 101

  @impl Tableau.Extension
  def pre_build(%{posts: posts} = token) do
    for post <- posts do
      doc = Pdx.Converters.MDExConverter.to_ast(post.body)

      Map.put(post, :mdex_document, doc)
    end
    |> then(&Map.put(token, :posts, &1))
    |> FE.Result.ok()
  end
end
