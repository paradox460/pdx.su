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
      {"pre", pre_attrs, [{"code", attrs, children}]} ->
        language =
          Enum.find_value(attrs, fn
            {"class", <<"language-" <> language>>} -> language
            _ -> false
          end)

        highlights =
          Enum.find_value(pre_attrs, [], fn
            {"highlight", highlights} ->
              highlights
              |> String.split(",")
              |> Enum.flat_map(fn
                highlight ->
                  Regex.named_captures(
                    ~r[^(?<line>\d+)$|^(?<lower>\d+)-(?<upper>\d+)(?:/+(?<step>\d+))?$],
                    highlight
                  )
                  |> case do
                    %{"line" => "", "lower" => "", "upper" => "", "step" => ""} ->
                      []

                    %{"line" => line} when line != "" ->
                      [String.to_integer(line)]

                    %{"lower" => lower, "upper" => upper, "step" => step} ->
                      lower = String.to_integer(lower)
                      upper = String.to_integer(upper)
                      step = String.to_integer(if step != "", do: step, else: "1")

                      Range.to_list(lower..upper//step)
                  end
              end)

            _ ->
              false
          end)

        formatter =
          (Application.get_env(:tableau, :config)[:markdown][:mdex][:syntax_highlight][:formatter] ||
             :html_inline)
          |> then(fn
            {formatter, opts} ->
              {formatter, Keyword.put(opts, :highlight_lines, %{lines: highlights})}

            formatter ->
              {formatter, highlight_lines: %{lines: highlights}}
          end)

        children
        |> Floki.text()
        |> Autumn.highlight!(language: language, formatter: formatter)
        |> Floki.parse_fragment!()
        |> Floki.find("pre")
        |> hd()
        |> merge_pre_attrs(pre_attrs)

      x ->
        x
    end)
  end

  defp merge_pre_attrs({_, code_attrs, _} = code_block, pre_attrs) do
    pre_attrs
    |> Enum.reject(fn
      {"highlight", _} -> true
      _ -> false
    end)
    |> Enum.concat(code_attrs)
    |> then(&put_elem(code_block, 1, &1))
  end
end
