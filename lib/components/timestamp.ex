defmodule Pdx.Components.Timestamp do
  use Pdx.Component

  # TODO: Make a Lit component pick this up and do some time magic for local users timezones
  # Yeah we'd get a flash of the old time, but meh idgaf

  def timestamp(assigns) do
    temple do
      time datetime: DateTime.to_iso8601(@t), title: Calendar.strftime(@t, "%c"), do: Calendar.strftime(@t, "%Y-%m-%d")
    end
  end
end
