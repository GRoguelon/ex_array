defmodule ExArray.InspectTest do
  use ExUnit.Case, async: true

  test "returns a formatted version of ExArray" do
    ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

    assert inspect(ex_array) == ~s(#ExArray<[nil, "1", nil, "3", nil], fixed=true, default=nil>)
  end

  test "respects the limit option" do
    ex_array = ExArray.from_list(Enum.to_list(1..100), 0)

    assert inspect(ex_array, limit: 3) == "#ExArray<[1, 2, 3, ...], fixed=false, default=0>"
  end

  test "formats the default value with the inspect options" do
    ex_array = ExArray.new(default: "x")

    assert inspect(ex_array, syntax_colors: [string: :red]) =~ "\e[31m\"x\""
  end
end
