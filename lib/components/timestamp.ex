defmodule Pdx.Components.Timestamp do
  use Phoenix.Component

  def timestamp(assigns) do
    ~H"""
    <smart-time t={DateTime.to_iso8601(@t)} hover show-timestamp={assigns[:timestamp]}></smart-time>
    <noscript>
      <time datetime={DateTime.to_iso8601(@t)} title={Calendar.strftime(@t, "%c")}>
        {Calendar.strftime(@t, "%Y-%m-%d")}
      </time>
    </noscript>
    """
  end
end
