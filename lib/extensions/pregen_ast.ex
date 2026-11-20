defmodule Pdx.Extensions.PregenAST do
  @moduledoc """
  Stores each post's converter (`:engine`) and parsed document (`:document`), so other
  extensions don't have to regenerate it, and renders the post from that document instead of
  re-parsing the body.
  """

  use Tableau.Extension, key: :pregen_ast, priority: 101

  @impl Tableau.Extension
  def pre_build(%{posts: posts} = token) do
    posts =
      for post <- posts do
        case Pdx.Converter.engine_for(post) do
          nil ->
            post

          engine ->
            document = Pdx.Converter.document(engine, post.body)

            Map.merge(post, %{
              engine: engine,
              document: document,
              renderer: fn _assigns -> engine.to_html!(document) end
            })
        end
      end

    {:ok, %{token | posts: posts}}
  end
end
