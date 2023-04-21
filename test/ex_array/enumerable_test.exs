defmodule ExArray.EnumerableTest do
  use ExUnit.Case, async: true

  describe "count/1" do
    test "returns zero" do
      ex_array = ExArray.new()

      assert Enum.count(ex_array) == 0
    end

    test "returns the number of elements" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      assert Enum.count(ex_array) == 5
    end
  end

  describe "member?/2" do
    test "returns false if empty array" do
      ex_array = ExArray.new()

      refute Enum.member?(ex_array, "0")
    end

    test "returns a boolean if element is in ExArray" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      assert Enum.member?(ex_array, "1")
      refute Enum.member?(ex_array, "2")
    end
  end

  describe "reduce/3" do
    test "returns empty list" do
      ex_array = ExArray.new()
      subject = Enum.reduce(ex_array, [], fn value, acc -> [value | acc] end)

      assert subject == []
    end

    test "returns the accumulator" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      subject =
        Enum.reduce(ex_array, [], fn
          nil, acc ->
            acc

          value, acc ->
            [value | acc]
        end)

      assert subject == ["3", "1"]
    end
  end

  describe "slice/1" do
    test "returns empty list" do
      ex_array = ExArray.new()

      assert Enum.slice(ex_array, 1..3) == []
    end

    test "returns a subset" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      assert Enum.slice(ex_array, 1..3) == ["1", nil, "3"]
    end
  end
end
