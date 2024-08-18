defmodule Pdx.PostLayout do
  use Pdx.Component
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

    temple do
      unless @page[:notoc] do
        nav id: "toc" do
          ul do
            for toc_link <- @toc[@page.file] || [] do
              li do
                a href: "##{toc_link.id}", "data-depth": toc_link.depth, do: toc_link.text
              end
            end
          end
        end
      end

      article id: "content", class: "post" do
        render(@inner_content)

        footer class: "articlefooter" do
          "The article &ldquo;#{@page.title}&rdquo; was written on "

          span do
            c(&Pdx.Components.Timestamp.timestamp/1, t: @page.date)
          end

          if @page[:updated] do
            "and last updated on "

            span do
              c(&Pdx.Components.Timestamp.timestamp/1, t: @page.updated)
            end
          end

          if @page[:amazon] do
            div class: "affiliate-banner" do
              "This post contains Amazon Affiliate links, marked with an "
              span class: "amazon-icon", do: nil
              "icon. As an Amazon Associate I earn from qualifying purchases."
            end
          end
        end
      end
    end
  end
end
