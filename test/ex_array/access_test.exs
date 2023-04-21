defmodule ExArray.AccessTest do
  use ExUnit.Case, async: true

  describe "fetch/2" do
    test "with valid index returns the value" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      assert Access.fetch(ex_array, 1) == {:ok, "1"}
    end

    test "with invalid index returns error" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      assert Access.fetch(ex_array, 0) == :error
    end

    test "with outbound index raises an error" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      assert_raise ArgumentError, fn ->
        Access.fetch(ex_array, 100)
      end
    end
  end

  describe "get_and_update/2" do
    test "with valid index returns the value" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      {previous, current} = Access.get_and_update(ex_array, 1, fn value -> {value, value <> "00"} end)

      assert previous == "1"
      assert ExArray.is_array(current)
      assert ExArray.to_list(current) == [nil, "100", nil, "3", nil]
    end

    test "with invalid index returns error" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      {previous, current} = Access.get_and_update(ex_array, 0, fn value -> {value, "0"} end)

      assert is_nil(previous)
      assert ExArray.is_array(current)
      assert ExArray.to_list(current) == ["0", "1", nil, "3", nil]
    end

    test "with outbound index raises an error" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      assert_raise ArgumentError, fn ->
        Access.get_and_update(ex_array, 100, fn value -> {value, "0"} end)
      end
    end
  end

  describe "pop/2" do
    test "with valid index returns the value" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      {value, ex_array} = Access.pop(ex_array, 1)

      assert value == "1"
      assert ExArray.is_array(ex_array)
      assert ExArray.to_list(ex_array) == [nil, nil, nil, "3", nil]
    end

    test "with invalid index returns nil" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      {value, ex_array} = Access.pop(ex_array, 0)

      assert is_nil(value)
      assert ExArray.is_array(ex_array)
      assert ExArray.to_list(ex_array) == [nil, "1", nil, "3", nil]
    end

    test "with outbound index raises an error" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      assert_raise ArgumentError, fn ->
        Access.pop(ex_array, 100)
      end
    end
  end
end
