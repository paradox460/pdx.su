defmodule Pdx.Converters.DjotConverter do
  def convert(_filepath, _front_matter, body, _site) do
    body
    |> to_ast()
    |> Floki.raw_html()
  end

  def to_ast(body) do
    Djot.to_html!(body)
    |> Floki.parse_fragment!()
    |> maybe_netlify_images()
    |> highlight_code_blocks()
  end

  defp maybe_netlify_images(ast) do
    if Application.get_env(:pdx, :netlify, false) do
      Floki.attr(ast, "img[src^='/postimages/']", "src", &"/.netlify/images?url=#{&1}")
    else
      ast
    end
  end

  defp highlight_code_blocks(ast) do
    ast
    |> Floki.traverse_and_update(fn
      {"pre", _attrs, [{"code", attrs, children}]} ->
        language =
          Enum.find_value(attrs, fn
            {"class", <<"language-" <> language>>} -> language
            _ -> false
          end)

        formatter =
          Application.get_env(:tableau, :config)[:markdown][:mdex][:syntax_highlight][:formatter] ||
            :html_inline

        children
        |> Floki.text()
        |> Autumn.highlight!(language: language, formatter: formatter)
        |> Floki.parse_fragment!()
        |> Floki.find("pre")
        |> hd()

      x ->
        x
    end)
  end
end
