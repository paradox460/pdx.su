defmodule Pdx.Converters.DjotConverter do
  @moduledoc "Djot converter backed by `Djot`."

  use Pdx.Converter, key: :pdx_djot

  @smart %{
    left_single_quote: "‘",
    right_single_quote: "’",
    left_double_quote: "“",
    right_double_quote: "”",
    ellipsis: "…",
    en_dash: "–",
    em_dash: "—"
  }

  @impl Pdx.Converter
  def new(source, options) do
    [source: source]
    |> Kernel.++(options)
    |> Djot.new()
    |> Djot.Document.append_steps(plaintext_code_blocks: &plaintext_code_blocks/1)
  end

  # Djot.Highlight skips language "" blocks; Autumn used to highlight them as plaintext
  # (pre.athl), so keep them styled. A predicate, not a struct selector: struct selectors
  # treat default-valued fields as wildcards and would match every code block.
  defp plaintext_code_blocks(doc) do
    Djot.Document.update_nodes(
      doc,
      &match?(%Djot.CodeBlock{language: ""}, &1),
      &%{&1 | language: "plaintext"}
    )
  end

  @impl Pdx.Converter
  def to_html!(document), do: Djot.to_html!(document)

  @impl Pdx.Converter
  def text_fragment(%Djot.Text{literal: literal}), do: literal
  def text_fragment(%Djot.Verbatim{literal: literal}), do: literal
  def text_fragment(%Djot.SmartPunctuation{kind: kind}), do: Map.fetch!(@smart, kind)
  def text_fragment(%Djot.NonBreakingSpace{}), do: "\u00A0"
  def text_fragment(%Djot.SoftBreak{}), do: " "
  def text_fragment(%Djot.HardBreak{}), do: " "
  def text_fragment(%Djot.Symbol{name: name}), do: ":#{name}:"
  def text_fragment(_node), do: ""

  @impl Pdx.Converter
  def heading_id(%Djot.Heading{id: id}, _text, seen), do: {id, seen}

  @impl Pdx.Converter
  def image_url(%{url: url}), do: url

  @impl Pdx.Converter
  def put_image_url(image, url), do: %{image | url: url}
end
