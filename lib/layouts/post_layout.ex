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
      |> put_source_url()

    ~H"""
    <nav :if={!@page[:notoc]} id="toc">
      <ul>
        <li :for={toc_link <- @page[:toc] || []}>
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

        <br/>

        <a href={@page.source_url} target="_blank">You can view its source here.</a>

        <div :if={@page[:amazon]} class="affiliate-banner">
          This post contains Amazon Affiliate links, marked with an <span class="amazon-icon"></span>
          icon. As an Amazon Associate I earn from qualifying purchases.
        </div>
      </footer>
      <%= if !@page[:nocomments] do %>
        <a id="comments"></a>
        <script
          src="https://giscus.app/client.js"
          data-repo="paradox460/pdx.su"
          data-repo-id="MDEwOlJlcG9zaXRvcnkxNjc4NTg5NzQ="
          data-category="Comments"
          data-category-id="DIC_kwDOCgFTHs4CljL1"
          data-mapping="pathname"
          data-strict="1"
          data-reactions-enabled="1"
          data-emit-metadata="0"
          data-input-position="top"
          data-theme="transparent_dark"
          data-lang="en"
          data-loading="lazy"
          crossorigin="anonymous"
          async
        >
        </script>
      <% end %>
    </article>
    """
  end

  defp put_source_url(%{page: %{file: file}} = assigns) do
    put_in(assigns, [:page, :source_url], "https://github.com/paradox460/pdx.su/tree/main/#{file}")
  end
end
