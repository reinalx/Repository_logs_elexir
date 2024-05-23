defmodule ElixirLogTest do
  use ExUnit.Case
  doctest ElixirLog

  test "greets the world" do
    assert ElixirLog.hello() == :world
  end
end
