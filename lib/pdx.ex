defmodule Pdx do
  def full_url(relative_url) do
    base_url = Application.get_env(:tableau, :config)[:url]
    URI.merge(base_url, relative_url) |> to_string()
  end
end
