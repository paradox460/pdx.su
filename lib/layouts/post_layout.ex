defmodule Pdx.PostLayout do
  use Phoenix.Component
  use Tableau.Layout, layout: Pdx.RootLayout

  def template(assigns) do
    assigns =
      if assigns.page[:updated] do
        assigns.page.updated
        |> DateTimeParser.parse_datetime!()
        |> then(&put_in(assigns.page.updated, &1))
      else
        assigns
      end

    ~H"""
    <nav :if={!@page[:notoc]} id="toc">
      <ul>
        <li :for={toc_link <- @toc[@page.file] || []}>
          <a href={"##{toc_link.id}"} data-depth={toc_link.depth}>{toc_link.text}</a>
        </li>
      </ul>
    </nav>

    <article id="content" class="post">
      {{:safe, render(@inner_content)}}

      <footer class="articlefooter">
        The article &ldquo;{@page.title}&rdquo; was written on
        <Pdx.Components.Timestamp.timestamp t={@page.date} />
        <%= if @page[:updated] do %>
          and last updated on <Pdx.Components.Timestamp.timestamp t={@page.updated} />
        <% end %>

        <div :if={@page[:amazon]} class="affiliate-banner">
          This post contains Amazon Affiliate links, marked with an <span class="amazon-icon"></span>
          icon. As an Amazon Associate I earn from qualifying purchases.
        </div>
      </footer>
    </article>
    """
  end
end
