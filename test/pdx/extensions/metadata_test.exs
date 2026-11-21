defmodule Pdx.Extensions.MetadataTest do
  use ExUnit.Case, async: true

  alias Pdx.Converters.{CarveConverter, MDExConverter}

  defp description(markdown) do
    post = %{engine: MDExConverter, document: Pdx.Converter.document(MDExConverter, markdown)}

    {:ok, %{posts: [%{metadata: %{description: description}}]}} =
      Pdx.Extensions.Metadata.pre_build(%{posts: [post]})

    description
  end

  test "keeps a short paragraph intact, without an ellipsis" do
    assert description("Just one sentence.\n") == "Just one sentence."
    assert description("One. Two!\n") == "One. Two!"
  end

  test "truncates after two sentences and marks the cut" do
    assert description("One. Two. Three.\n") == "One. Two…"
  end

  test "does not split on abbreviations or decimals" do
    assert description("Use e.g. version 1.5 here. Then more. And more.\n") ==
             "Use e.g. version 1.5 here. Then more…"
  end

  test "Carve image uses src" do
    post = %{
      engine: CarveConverter,
      document: Pdx.Converter.document(CarveConverter, "![a](/postimages/a.png)\n")
    }

    {:ok, %{posts: [%{metadata: metadata}]}} = Pdx.Extensions.Metadata.pre_build(%{posts: [post]})
    assert metadata.image == "https://pdx.su/postimages/a.png"
  end
end
