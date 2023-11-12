defmodule Pdx.Index do
  use Pdx.Component

  use Tableau.Page,
    layout: Pdx.RootLayout,
    permalink: "/"

  def template(assigns) do
    temple do
      ul id="content" do
        for post <- @posts do
          li do
            a href: "post.permalink", do: post.title
            c &Pdx.Components.Timestamp.timestamp/1, t: post.date
          end
        end
      end
    end
  end
end
