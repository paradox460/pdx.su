defmodule Pdx.Converters.MDExConverter do
  @moduledoc "Markdown converter backed by `MDEx`."

  use Pdx.Converter, key: :pdx_mdex

  @impl Pdx.Converter
  def new(source, options), do: MDEx.new([markdown: source] ++ options)

  @impl Pdx.Converter
  def to_html!(document), do: MDEx.to_html!(document)

  @impl Pdx.Converter
  def text_fragment(%MDEx.Text{literal: literal}), do: literal
  def text_fragment(%MDEx.Code{literal: literal}), do: literal
  def text_fragment(%MDEx.SoftBreak{}), do: " "
  def text_fragment(%MDEx.LineBreak{}), do: " "
  def text_fragment(_node), do: ""

  # Mirrors comrak's header id de-duplication: the first occurrence keeps the bare id,
  # later ones get `-1`, `-2`, ...
  @impl Pdx.Converter
  def heading_id(_heading, text, seen) do
    id = MDEx.anchorize(text)

    case Map.get(seen, id, 0) do
      0 -> {id, Map.put(seen, id, 1)}
      n -> {"#{id}-#{n}", Map.put(seen, id, n + 1)}
    end
  end
end
