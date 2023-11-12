defmodule PdxTest do
  use ExUnit.Case
  doctest Pdx

  test "greets the world" do
    assert Pdx.hello() == :world
  end
end
