defmodule Pdx.PageLayout do
  use Pdx.Component
  use Tableau.Layout, layout: Pdx.RootLayout

  def template(assigns) do
    temple do
      article id: "content", class: "page" do
        render(@inner_content)
      end
    end
  end
end
