defmodule HelloPortTest do
  use ExUnit.Case
  doctest HelloPort

  test "greets the world" do
    assert HelloPort.hello() == :world
  end
end
