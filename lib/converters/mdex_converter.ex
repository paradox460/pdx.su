defmodule Pdx.Converters.MDExConverter do
  alias MDEx.Pipe

  def convert(_filepath, _front_matter, body, _site) do
    body
    |> pipeline()
    |> MDEx.to_html!()
  end

  def to_ast(body, options \\ []) do
    body
    |> pipeline(options)
    |> Pipe.run()
    |> Map.get(:document)
  end

  def pipeline(source, options \\ []) do
    options =
      Application.get_env(:tableau, :config)[:markdown][:mdex]
      |> Keyword.merge(options)
      |> Keyword.put(:document, source)

    MDEx.new(options)
    |> maybe_netlify_images()
  end

  defp maybe_netlify_images(pipe) do
    if Application.get_env(:pdx, :netlify, false) do
      Pipe.append_steps(pipe, netlify_images: &do_netlify_images/1)
    else
      pipe
    end
  end

  defp do_netlify_images(pipe) do
    selector = fn
      %MDEx.Image{url: <<"/postimages/", _::binary>>} -> true
      _ -> false
    end

    Pipe.update_nodes(pipe, selector, fn %MDEx.Image{url: original_url} = image ->
      %MDEx.Image{image | url: "/.netlify/images?url=" <> original_url}
    end)
  end
end
