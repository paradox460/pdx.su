defmodule Pdx.Components.Timestamp do
  use Pdx.Component

  def timestamp(assigns) do
    temple do
      ~s[<smart-time t='#{DateTime.to_iso8601(@t)}' hover #{if assigns[:timestamp], do: "show-timestamp"}></smart-time>]

      noscript do
        time datetime: DateTime.to_iso8601(@t),
             title: Calendar.strftime(@t, "%c"),
             do: Calendar.strftime(@t, "%Y-%m-%d")
      end
    end
  end
end
