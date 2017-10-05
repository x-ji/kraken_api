defmodule KrakenApiTest do
  use ExUnit.Case
  doctest KrakenApi

  test "greets the world" do
    assert KrakenApi.hello() == :world
  end
end
