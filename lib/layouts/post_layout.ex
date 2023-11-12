defmodule Pdx.PostLayout do
  use Pdx.Component
  use Tableau.Layout, layout: Pdx.RootLayout

  def template(assigns) do
    temple do
      # TODO: TOC
      article id: "content", class: "post" do
        render(@inner_content)
        footer class: "articlefooter" do
          "The article #{@page.title} was written on "
          c &Pdx.Components.Timestamp.timestamp/1, t: @page.date
          if @page[:updated] do
            "and last updated on "
          end
        end
      end
    end
  end
end
