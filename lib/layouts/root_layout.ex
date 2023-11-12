defmodule Pdx.RootLayout do
  use Pdx.Component
  use Tableau.Layout

  def template(assigns) do
    temple do
      "<!DOCTYPE html>"

      html lang: "en" do
        head do
          meta charset: "utf-8"

          meta name: "theme-color", media: "(prefers-color-scheme: light)", content: "#ffffff"
          meta name: "theme-color", media: "(prefers-color-scheme: dark)", content: "#1d1f21"

          meta name: "viewport", content: "width=device-width, initial-scale=1.0"

          meta name: "description", content: "The personal blog of software engineer Jeff Sandberg"
          meta name: "author", content: "Jeff Sandberg"
          meta property: "og:locale", content: "en_US"
          meta property: "twitter:site", content: "@paradox460"

          title do
            [@page[:title], "pdx.su"]
            |> Enum.filter(& &1)
            |> Enum.inersperse("•")
            |> Enum.join(" ")
          end

          link  rel: 'stylesheet', href: 'https://use.typekit.net/fln1ury.css'
          link rel: "stylesheet", href: "/css/style.css"
          link  rel: 'manifest', href: '/manifest.webmanifest'
          link  rel: 'icon', href: '/favicon.ico', sizes: 'any'
          link  rel: 'icon', href: '/favicon.svg', type: 'image/svg+xml'
          link  rel: 'apple-touch-icon', href: '/apple-touch-icon.png'
          link  rel: 'alternate', type: 'application/rss+xml', href: '/rss.xml'

          # TODO: Meta tags from posts
        end

        body do
          svg style: "display: none", xmlns: "http://www.w3.org/2000/svg" do
            symbol id="copy", viewBox="0 0 24 24" do
              path d: "M15 20H5V7c0-.55-.45-1-1-1s-1 .45-1 1v13c0 1.1.9 2 2 2h10c.55 0 1-.45 1-1s-.45-1-1-1zm5-4V4c0-1.1-.9-2-2-2H9c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h9c1.1 0 2-.9 2-2zm-2 0H9V4h9v12z"
            end
          end
          main do
            c &navbar/1, data: @data
            render(@inner_content)
            c &footer/1, data: @data
          end
        end

      end
    end
  end

  def navbar(assigns) do
    temple do
      nav id="navigation" do
        ul do
          li do: a href: "/", title: "Home", class: "logo", do: "Jeff Sandberg"
          li do: a href: "/", do: "Blog"
          li do: a href: "/about", do: "about"
        end
      end
    end
  end

  def footer(assigns) do
    temple do
      footer id="footer" do
        div do: "&copy; 2023 Jeff Sandberg"
        div do: "All writings are my own and do not reflect the opinion of any other party"
      end
    end
  end
end
