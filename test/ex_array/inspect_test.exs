defmodule ExArray.InspectTest do
  use ExUnit.Case, async: true

  test "returns a formatted version of ExArray" do
    ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

    assert inspect(ex_array) == ~s(#ExArray<[nil, "1", nil, "3", nil], fixed=true, default=nil>)
  end
end
