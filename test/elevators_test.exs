defmodule ElevatorsTest do
  use ExUnit.Case
  doctest Elevators

  test "greets the world" do
    assert Elevators.hello() == :world
  end
end
