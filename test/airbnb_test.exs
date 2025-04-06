defmodule AirbnbTest do
  use ExUnit.Case
  doctest Airbnb

  test "greets the world" do
    assert Airbnb.hello() == :world
  end
end
