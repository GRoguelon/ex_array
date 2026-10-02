defmodule ExArray.AccessTest do
  use ExUnit.Case, async: true

  describe "fetch/2" do
    test "with an index in bounds returns the value" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      assert Access.fetch(ex_array, 1) == {:ok, "1"}
    end

    test "with an index in bounds holding the default value returns the default value" do
      ex_array = ExArray.new(size: 3, default: 0) |> ExArray.set(1, 0)

      assert Access.fetch(ex_array, 0) == {:ok, 0}
      assert Access.fetch(ex_array, 1) == {:ok, 0}
    end

    test "with stored falsy values returns them" do
      ex_array = ExArray.new(size: 2, default: :unset) |> ExArray.set(0, false)

      assert Access.fetch(ex_array, 0) == {:ok, false}
      assert Access.fetch(ex_array, 1) == {:ok, :unset}
    end

    test "with an index out of bounds returns error" do
      fixed = ExArray.new(size: 5)
      extendible = ExArray.from_list([1, 2])

      assert Access.fetch(fixed, 5) == :error
      assert Access.fetch(fixed, 100) == :error
      assert Access.fetch(extendible, 2) == :error
      assert Access.fetch(ExArray.new(), 0) == :error
    end

    test "with an invalid index returns error" do
      ex_array = ExArray.from_list([1, 2])

      assert Access.fetch(ex_array, -1) == :error
      assert Access.fetch(ex_array, :a) == :error
      assert Access.fetch(ex_array, 1.0) == :error
    end
  end

  describe "Access.get/3 and the bracket syntax" do
    test "returns the same value as ExArray.get/2 for indexes in bounds" do
      ex_array = ExArray.from_list([1, 0, 3], 0)

      assert ex_array[1] == 0
      assert ex_array[1] == ExArray.get(ex_array, 1)
      assert Access.get(ex_array, 1, :missing) == 0
    end

    test "returns nil or the given default for indexes out of bounds" do
      ex_array = ExArray.new(size: 2)

      assert ex_array[2] == nil
      assert ex_array[-1] == nil
      assert Access.get(ex_array, 2, :missing) == :missing
    end

    test "works with nested data" do
      data = %{list: ExArray.from_list([%{a: 1}, %{a: 2}])}

      assert get_in(data, [:list, 1, :a]) == 2
      assert get_in(data, [:list, 5, :a]) == nil
    end
  end

  describe "get_and_update/3" do
    test "with an index in bounds updates the value" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      {previous, current} =
        Access.get_and_update(ex_array, 1, fn value -> {value, value <> "00"} end)

      assert previous == "1"
      assert ExArray.to_list(current) == [nil, "100", nil, "3", nil]
    end

    test "passes the default value of unset entries" do
      ex_array = ExArray.new(size: 2, default: 0)

      {previous, current} = Access.get_and_update(ex_array, 0, fn value -> {value, value + 1} end)

      assert previous == 0
      assert ExArray.to_list(current) == [1, 0]
    end

    test "with an index out of bounds of an extendible array passes nil and grows it" do
      ex_array = ExArray.from_list([:a])

      {previous, current} = Access.get_and_update(ex_array, 2, fn value -> {value, :c} end)

      assert previous == nil
      assert ExArray.to_list(current) == [:a, nil, :c]
    end

    test "with an index out of bounds of a fixed array raises an error" do
      ex_array = ExArray.new(size: 5)

      assert_raise ArgumentError, fn ->
        Access.get_and_update(ex_array, 100, fn value -> {value, "0"} end)
      end
    end

    test "with :pop resets the entry and returns the value" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      {previous, current} = Access.get_and_update(ex_array, 1, fn _value -> :pop end)

      assert previous == "1"
      assert ExArray.to_list(current) == [nil, nil, nil, "3", nil]
    end

    test "with :pop and an index out of bounds returns nil and the array unchanged" do
      ex_array = ExArray.new(size: 2)

      assert Access.get_and_update(ex_array, 5, fn _value -> :pop end) == {nil, ex_array}
    end

    test "works with put_in/2 and update_in/2" do
      ex_array = ExArray.from_list([1, 2, 3])

      assert ex_array |> put_in([1], 20) |> ExArray.to_list() == [1, 20, 3]
      assert ex_array |> update_in([2], &(&1 * 10)) |> ExArray.to_list() == [1, 2, 30]
    end
  end

  describe "pop/2" do
    test "with an index in bounds returns the value and resets the entry" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      {value, ex_array} = Access.pop(ex_array, 1)

      assert value == "1"
      assert ExArray.to_list(ex_array) == [nil, nil, nil, "3", nil]
      assert ExArray.size(ex_array) == 5
    end

    test "with an index in bounds holding the default value returns the default value" do
      ex_array = ExArray.new(size: 2, default: 0)

      assert {0, popped} = Access.pop(ex_array, 0)
      assert ExArray.equal?(popped, ex_array)
    end

    test "with stored falsy values returns them and resets the entries" do
      ex_array =
        ExArray.new(size: 3, default: :unset) |> ExArray.set(0, false) |> ExArray.set(1, nil)

      {value, ex_array} = Access.pop(ex_array, 0)

      assert value == false
      assert ExArray.get(ex_array, 0) == :unset

      {value, ex_array} = Access.pop(ex_array, 1)
      assert is_nil(value)
      assert ExArray.get(ex_array, 1) == :unset
    end

    test "with an index out of bounds returns nil and the array unchanged" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1")

      assert Access.pop(ex_array, 100) == {nil, ex_array}
      assert Access.pop(ex_array, -1) == {nil, ex_array}
      assert Access.pop(ex_array, :a) == {nil, ex_array}
    end

    test "works with pop_in/2" do
      ex_array = ExArray.from_list([1, 2, 3])
      {value, ex_array} = pop_in(ex_array, [1])

      assert value == 2
      assert ExArray.to_list(ex_array) == [1, nil, 3]
    end
  end
end
