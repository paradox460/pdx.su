defmodule Pdx.Converter do
  @moduledoc """
  Engine-agnostic conversion pipeline shared by the Markdown (MDEx) and Djot converters.

  `MDEx.Document` and `Djot.Document` share the pipeline API this module relies on
  (`append_steps/2`, `update_nodes/3`, `run/1`, Access, pre-order `Enumerable`), so the
  generic code dispatches on the document struct's module. Each engine implements the
  callbacks below for the parts that differ.
  """

  @type document :: MDEx.Document.t() | Djot.Document.t()
  @type toc_entry :: %{text: String.t(), id: String.t(), depth: 2..4}

  @callback new(source :: String.t(), options :: keyword()) :: document()
  @callback to_html!(document()) :: String.t()
  @callback text_fragment(node :: struct()) :: String.t()
  @callback heading_id(
              heading :: struct(),
              text :: String.t(),
              seen :: %{String.t() => pos_integer()}
            ) :: {String.t(), %{String.t() => pos_integer()}}

  defmacro __using__(opts) do
    quote do
      use Tableau.Extension, key: unquote(opts[:key])
      @behaviour Pdx.Converter

      @impl Tableau.Extension
      def convert(body), do: Pdx.Converter.convert(__MODULE__, body)
    end
  end

  @doc "Parses `source` with `engine`, applies the common steps, and runs the pipeline."
  @spec document(module(), String.t()) :: document()
  def document(engine, source) do
    source
    |> engine.new(Application.get_env(:tableau, engine, []))
    |> maybe_netlify_images()
    |> run()
  end

  @doc "Converts `source` to HTML with `engine`."
  @spec convert(module(), String.t()) :: String.t()
  def convert(engine, source), do: engine.to_html!(document(engine, source))

  @doc "Plain text of `node` and its descendants."
  @spec text(module(), struct()) :: String.t()
  def text(engine, node), do: Enum.map_join(node, &engine.text_fragment/1)

  @doc """
  Table of contents for h2–h4 headings. Every heading feeds the id de-duplication, so ids
  match the ones the engine renders.
  """
  @spec toc(module(), document()) :: [toc_entry()]
  def toc(engine, doc) do
    doc[:heading]
    |> List.wrap()
    |> Enum.flat_map_reduce(%{}, fn heading, seen ->
      text = text(engine, heading)
      {id, seen} = engine.heading_id(heading, text, seen)

      if heading.level in 2..4 and text != "" do
        {[%{text: text, id: id, depth: heading.level}], seen}
      else
        {[], seen}
      end
    end)
    |> elem(0)
  end

  @doc "The converter configured for the post's file extension, or `nil`."
  @spec engine_for(map()) :: module() | nil
  def engine_for(post), do: Application.get_env(:tableau, :config)[:converters][post.ext]

  defp maybe_netlify_images(%mod{} = doc) do
    if Application.get_env(:pdx, :netlify, false) do
      mod.append_steps(doc, netlify_images: &netlify_images/1)
    else
      doc
    end
  end

  defp netlify_images(%mod{} = doc) do
    mod.update_nodes(doc, :image, fn
      %{url: "/postimages/" <> _ = url} = image -> %{image | url: "/.netlify/images?url=" <> url}
      image -> image
    end)
  end

  defp run(%mod{} = doc) do
    case mod.run(doc) do
      {_doc, exception} -> raise exception
      doc -> doc
    end
  end
end
