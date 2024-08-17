defmodule Pdx.HtmlConverter do
  def convert(filepath, body, attrs, opts) do
    Tableau.PostExtension.Posts.HTMLConverter.convert(filepath, body, attrs, opts)
    |> maybe_netlify_images()
  end

  defp maybe_netlify_images(html) do
    cdn = Application.get_env(:pdx, :netlify, false)
    do_netlify_images(html, cdn)
  end

  defp do_netlify_images(html, true) do
    html
    |> Floki.parse_fragment!()
    |> Floki.traverse_and_update(fn
      {"img", attrs, children} ->
        attrs =
          attrs
          |> Enum.map(fn
            {"src", src} ->
              {"src", "/.netlify/images?url=" <> src}

            other ->
              other
          end)

        {"img", attrs, children}

      other ->
        other
    end)
    |> Floki.raw_html()
  end

  defp do_netlify_images(html, _false), do: html
end
