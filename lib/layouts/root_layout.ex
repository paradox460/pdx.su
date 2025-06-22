defmodule Pdx.RootLayout do
  use Phoenix.Component
  use Tableau.Layout

  def template(assigns) do
    assigns =
      assigns
      |> remap_metadata()
      |> title()

    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="theme-color" media="(prefers-color-scheme: light)" content="#ffffff" />
        <meta name="theme-color" media="(prefers-color-scheme: dark)" content="#1d1f21" />

        <meta name="viewport" content="width=device-width, initial-scale=1.0" />

        <title>{@title}</title>

        <meta property="og:title" content={@title} />
        <meta property="og:type" content="article" />
        <meta
          property="og:description"
          content={@meta[:description] || "The personal blog of software engineer Jeff Sandberg"}
        />
        <meta :if={@meta[:image]} property="og:image" content={@meta[:image]} />
        <meta name="author" content="Jeff Sandberg" />
        <meta property="og:locale" content="en_US" />
        <meta property="twitter:site" content="@paradox460" />
        <meta property="og:site_name" content="pdx.su" />
        <meta property="og:url" content={Pdx.full_url(@page[:permalink])} />
        <meta name="twitter:card" content="summary_large_image" />

        <link rel="stylesheet" href="https://use.typekit.net/fln1ury.css" />
        <link rel="stylesheet" href="/css/style.css" />
        <link rel="manifest" href="/manifest.webmanifest" />
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="icon" href="/favicon.svg" type="image/svg+xml" />
        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
        <link rel="alternate" type="application/rss+xml" href="/feed.xml" />
        <link rel="sitemap" type="application/xml" title="Sitemap" href="/sitemap.xml" />

        <script src="/js/index.js">
        </script>
        <.analytics />
      </head>
      <body>
        <main>
          <.navbar />
          {render(@inner_content)}
          <.footer />
          <%= if Mix.env() == :dev do %>
            {Phoenix.HTML.raw(Tableau.live_reload(assigns))}
          <% end %>
        </main>
      </body>
    </html>
    """
    |> Phoenix.HTML.Safe.to_iodata()
  end

  def navbar(assigns) do
    ~H"""
    <nav id="navigation">
      <ul>
        <li><a href="/" title="Home" class="logo">Jeff Sandberg</a></li>
        <li><a href="/">Blog</a></li>
        <li><a href="/about">About</a></li>
      </ul>
    </nav>
    """
  end

  def footer(assigns) do
    ~H"""
    <footer id="footer">
      <nav id="footer-navigation">
        <ul>
          <li><a href="/">blog</a></li>
          <li><a href="/about">about</a></li>
          <li><a href="/feed.xml">rss</a></li>
          <li><a href="https://plausible.io/pdx.su/" target="_BLANK">stats</a></li>
          <li><a href="https://github.com/paradox460/pdx.su" target="_blank">source</a></li>
        </ul>
      </nav>
      <div>&copy; {DateTime.now!("Etc/UTC").year} Jeff Sandberg</div>
      <div>
        built in utah with &hearts; and
        <a href="https://github.com/elixir-tools/tableau" target="_blank">tableau</a>
      </div>
      <div>all writings are my own and do not reflect the opinion of any other party</div>
    </footer>
    """
  end

  defp analytics_file, do: "script.outbound-links.js"

  defp analytics(assigns) do
    ~H"""
    <%= if Mix.env() == :prod do %>
      <%= if Application.get_env(:pdx, :netlify) do %>
        <script defer data-domain="pdx.su" data-api="/pa/api/event" src={"/pa/js/#{analytics_file()}"}>
        </script>
      <% else %>
        <script defer data-domain="pdx.su" src={"https://plausible.io/js/#{analytics_file()}"}>
        </script>
      <% end %>
    <% end %>
    """
  end

  defp remap_metadata(%{page: page} = assigns) do
    Map.put(assigns, :meta, Map.get(page, :metadata, %{}))
  end

  defp title(%{page: page} = assigns) do
    [page[:title], "pdx.su"]
    |> Enum.filter(& &1)
    |> Enum.intersperse("•")
    |> Enum.join(" ")
    |> then(&Map.put(assigns, :title, &1))
  end
end
