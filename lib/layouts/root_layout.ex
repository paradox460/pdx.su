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

          meta name: "description",
               content: "The personal blog of software engineer Jeff Sandberg"

          meta name: "author", content: "Jeff Sandberg"
          meta property: "og:locale", content: "en_US"
          meta property: "twitter:site", content: "@paradox460"

          title do
            [@page[:title], "pdx.su"]
            |> Enum.filter(& &1)
            |> Enum.intersperse("•")
            |> Enum.join(" ")
          end

          link rel: "stylesheet", href: "https://use.typekit.net/fln1ury.css"
          link rel: "stylesheet", href: "/css/style.css"
          link rel: "manifest", href: "/manifest.webmanifest"
          link rel: "icon", href: "/favicon.ico", sizes: "any"
          link rel: "icon", href: "/favicon.svg", type: "image/svg+xml"
          link rel: "apple-touch-icon", href: "/apple-touch-icon.png"
          link rel: "alternate", type: "application/rss+xml", href: "/feed.xml"
          link rel: "sitemap", type: "application/xml", title: "Sitemap", href: "/sitemap.xml"

          script src: "/js/index.js"

          # TODO: Meta tags from posts
        end

        body do
          main do
            c &navbar/1
            render(@inner_content)
            c &footer/1

            if Mix.env() == :dev do
              c &Tableau.live_reload/1
            end
          end
        end
      end
    end
  end

  def navbar(_) do
    temple do
      nav id: "navigation" do
        ul do
          li do: a(href: "/", title: "Home", class: "logo", do: "Jeff Sandberg")
          li do: a(href: "/", do: "Blog")
          li do: a(href: "/about", do: "About")
        end
      end
    end
  end

  def footer(_) do
    temple do
      footer id: "footer" do
        nav id: "footer-navigation" do
          ul do
            li do: a(href: "/", do: "blog")
            li do: a(href: "/about", do: "about")

            li do:
                 a(
                   href: "https://github.com/paradox460/pdx.su",
                   target: "_blank",
                   do: "source"
                 )
          end
        end

        div do: "&copy; #{DateTime.now!("Etc/UTC").year} Jeff Sandberg"
        div do: "built in utah with &hearts; and <a href='https://github.com/elixir-tools/tableau' target='_blank'>tableau</a>"
        div do: "all writings are my own and do not reflect the opinion of any other party"
      end
    end
  end
end
