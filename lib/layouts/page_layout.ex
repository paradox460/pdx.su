defmodule Pdx.PageLayout do
  use Phoenix.Component
  use Tableau.Layout, layout: Pdx.RootLayout

  def template(assigns) do
    ~H"""
    <article id="content" class="page">
      {{:safe, render(@inner_content)}}
    </article>
    """
  end
end
