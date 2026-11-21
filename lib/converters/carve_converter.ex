defmodule Pdx.Converters.CarveConverter do
  @moduledoc "Carve converter backed by `Carvex`."

  use Pdx.Converter, key: :pdx_carve

  # carve-rs leaves `glyph` nil for these kinds; quotes carry their glyph.
  @smart %{"ellipsis" => "…", "en_dash" => "–", "em_dash" => "—"}

  @impl Pdx.Converter
  def new(source, options) do
    [source: source]
    |> Kernel.++(options)
    |> Carvex.new()
    |> Carvex.Document.append_steps(plaintext_code_blocks: &plaintext_code_blocks/1)
  end

  # Carvex's highlighter skips blocks without a language; highlight them as plaintext so
  # bare fences are styled like the Djot ones. A predicate, not a struct selector: struct
  # selectors treat default-valued fields as wildcards and would match every code block.
  defp plaintext_code_blocks(doc) do
    Carvex.Document.update_nodes(
      doc,
      &match?(%Carvex.CodeBlock{lang: lang} when lang in [nil, ""], &1),
      &%{&1 | lang: "plaintext"}
    )
  end

  @impl Pdx.Converter
  def to_html!(document), do: Carvex.to_html!(document)

  @impl Pdx.Converter
  def text_fragment(%Carvex.Text{value: value}), do: value
  def text_fragment(%Carvex.Code{value: value}), do: value
  def text_fragment(%Carvex.EscapedText{value: value}), do: value
  def text_fragment(%Carvex.SmartPunctuation{glyph: glyph}) when is_binary(glyph), do: glyph

  def text_fragment(%Carvex.SmartPunctuation{kind: kind, value: value}),
    do: Map.get(@smart, kind, value)

  def text_fragment(%Carvex.NonBreakingSpace{}), do: "\u00A0"
  def text_fragment(%Carvex.SoftBreak{}), do: " "
  def text_fragment(%Carvex.HardBreak{}), do: " "
  def text_fragment(%Carvex.Symbol{name: name}), do: ":#{name}:"
  def text_fragment(_node), do: ""

  # carve-rs assigns (and de-duplicates) heading ids at parse time.
  @impl Pdx.Converter
  def heading_id(%Carvex.Heading{attrs: %Carvex.Attributes{id: id}}, _text, seen), do: {id, seen}

  @impl Pdx.Converter
  def image_url(%Carvex.Image{src: src}), do: src

  @impl Pdx.Converter
  def put_image_url(%Carvex.Image{} = image, url), do: %{image | src: url}
end
