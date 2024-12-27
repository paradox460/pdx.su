defmodule Pdx.Index do
  use Phoenix.Component

  use Tableau.Page,
    layout: Pdx.RootLayout,
    permalink: "/"

  def template(assigns) do
    ~H"""
    <ul class="index" id="content">
      <li :for={post <- @posts}>
        <a href={post.permalink}>{post.title}</a>
        <Pdx.Components.Timestamp.timestamp t={post.date} />
      </li>
    </ul>
    """
  end
end
