defmodule Pdx.Extensions.PregenAST do
  @moduledoc """
  Stores the current posts "document" in the token, so other extensions don't have to regen it
  """

  use Tableau.Extension, key: :pregen_ast, priority: 101

  @impl Tableau.Extension
  def pre_build(%{posts: posts} = token) do
    for post <- posts do
      case Path.extname(post.file) do
        ".md" ->
        doc = Pdx.Converters.MDExConverter.to_ast(post.body)

        Map.put(post, :mdex_document, doc)
        ".dj" ->
          doc = Pdx.Converters.DjotConverter.to_ast(post.body)

          Map.put(post, :djot_document, doc)
        _ ->
          post
        end
    end
    |> then(&Map.put(token, :posts, &1))
    |> FE.Result.ok()
  end
end
