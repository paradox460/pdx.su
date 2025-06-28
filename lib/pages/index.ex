defmodule Pdx.Index do
  use Phoenix.Component

  use Tableau.Page,
    layout: Pdx.RootLayout,
    permalink: "/"

  def template(assigns) do
    assigns = group_posts_by_year(assigns)

    ~H"""
    <ul class="index" id="content">
      <%= for {{year, posts}, index} <- @posts |> Enum.with_index() do %>
        <li :if={index > 0} class="year">
          <hr class="year-divider" />
          <div class="year-label">{year}</div>
        </li>
        <li :for={post <- posts}>
          <a href={post.permalink}>{post.title}</a>
          <Pdx.Components.Timestamp.timestamp t={post.date} />
        </li>
      <% end %>
    </ul>
    """
  end

  defp group_posts_by_year(%{posts: posts} = assigns) do
    posts
    |> Enum.group_by(& &1.date.year)
    |> Enum.into([])
    |> Enum.sort_by(fn {year, _posts} -> year end, :desc)
    |> then(&Map.put(assigns, :posts, &1))
  end
end
