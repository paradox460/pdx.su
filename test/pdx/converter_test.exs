defmodule Pdx.ConverterTest do
  # Not async: the netlify test toggles global application env.
  use ExUnit.Case, async: false

  alias Pdx.Converter
  alias Pdx.Converters.{DjotConverter, MDExConverter}

  describe "toc/2" do
    test "MDEx ids match rendered headings, including duplicates and inline code" do
      source = "## Foo\n\n## Foo\n\n### Using `mix` here\n\n# Foo\n"
      toc = Converter.toc(MDExConverter, Converter.document(MDExConverter, source))
      html = MDExConverter.convert(source)

      assert [%{id: "foo", depth: 2}, %{id: "foo-1", depth: 2}, third] = toc
      assert %{text: "Using mix here", depth: 3} = third
      for %{id: id} <- toc, do: assert(html =~ ~s(id="#{id}"))
    end

    test "Djot uses section ids and smart punctuation" do
      source = "# Title\n\n## Don't stop\n\n## Two\n"
      toc = Converter.toc(DjotConverter, Converter.document(DjotConverter, source))
      html = DjotConverter.convert(source)

      assert Enum.map(toc, & &1.text) == ["Don’t stop", "Two"]
      assert Enum.map(toc, & &1.depth) == [2, 2]
      for %{id: id} <- toc, do: assert(html =~ ~s(id="#{id}"))
    end
  end

  describe "netlify image rewrite" do
    setup do
      previous = Application.fetch_env(:pdx, :netlify)
      Application.put_env(:pdx, :netlify, true)

      on_exit(fn ->
        case previous do
          {:ok, value} -> Application.put_env(:pdx, :netlify, value)
          :error -> Application.delete_env(:pdx, :netlify)
        end
      end)
    end

    for engine <- [MDExConverter, DjotConverter] do
      test "rewrites local post images only (#{inspect(engine)})" do
        html =
          unquote(engine).convert("![a](/postimages/a.png) ![b](https://example.com/b.png)\n")

        assert html =~ ~s(src="/.netlify/images?url=/postimages/a.png")
        assert html =~ ~s(src="https://example.com/b.png")
      end
    end
  end

  describe "highlighting" do
    test "Djot fenced code uses Lumis linked HTML" do
      html = DjotConverter.convert("``` elixir\nIO.puts(1)\n```\n")
      assert html =~ ~s(<pre class="lumis)
      assert html =~ "l-line"
    end

    test "Djot bare fence is still styled" do
      assert DjotConverter.convert("```\nplain\n```\n") =~ ~s(<pre class="lumis)
    end

    test "Djot highlight_lines marks lines" do
      html = DjotConverter.convert(~s[{highlight_lines="1"}\n``` elixir\nIO.puts(1)\n```\n])
      assert html =~ "l-highlighted"
    end

    test "MDEx fenced code uses Lumis linked HTML" do
      html = MDExConverter.convert("```elixir\nIO.puts(1)\n```\n")
      assert html =~ ~s(<pre class="lumis)
      assert html =~ "l-line"
    end
  end

  test "text/2 excludes footnote markers" do
    doc = Converter.document(DjotConverter, "It's a test[^1].\n\n[^1]: note\n")
    assert Converter.text(DjotConverter, hd(doc[:paragraph])) == "It’s a test."
  end
end
