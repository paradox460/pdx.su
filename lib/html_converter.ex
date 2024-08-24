defmodule Pdx.HtmlConverter do
  def convert(filepath, body, attrs, opts) do
    Tableau.PostExtension.Posts.HTMLConverter.convert(filepath, body, attrs, opts)
    |> maybe_netlify_images()
  end

  defp maybe_netlify_images(html) do
    cdn = Application.get_env(:pdx, :netlify, false)
    do_netlify_images(html, cdn)
  end

  # This is an ugly hack to rewrite the urls in images to use netlify.
  # I have to do it because a nicer system, i.e. one using Floki to parse and
  # reoutput the document, unfortunately clobbers all the spacing in the HTML,
  # which wrecks havock on my code blocks
  #
  # An alternative solution would be make a rustler package or whatever that
  # implements lol-html's rewriter, as that doesn't seem to mangle HTML quite so
  # much. Maybe I'll do that later
  defp do_netlify_images(html, true) do
    String.replace(html, ~r[src="(/postimages/.*?)"], ~s[src="/.netlify/images?url=\\1"])
  end

  defp do_netlify_images(html, _false), do: html
end
