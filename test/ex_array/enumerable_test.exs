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

    test "supports start/length form" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      assert Enum.slice(ex_array, 0, 2) == [nil, "1"]
      assert Enum.slice(ex_array, 2, 3) == [nil, "3", nil]
      assert Enum.slice(ex_array, 4, 5) == [nil]
    end

    test "supports stepped ranges" do
      ex_array = ExArray.from_list([:a, :b, :c, :d, :e, :f])

      assert Enum.slice(ex_array, 0..5//2) == [:a, :c, :e]
      assert Enum.slice(ex_array, 1..5//2) == [:b, :d, :f]
      assert Enum.slice(ex_array, 0..5//3) == [:a, :d]
    end
  end

  describe "reduce/3 halting and suspension" do
    test "halts early" do
      ex_array = ExArray.from_list([:a, :b, :c, :d])

      assert Enum.take(ex_array, 2) == [:a, :b]
      assert Enum.find(ex_array, &(&1 == :c)) == :c
      assert Enum.take_while(ex_array, &(&1 != :c)) == [:a, :b]
    end

    test "suspends and resumes" do
      ex_array = ExArray.from_list([:a, :b, :c])

      assert Enum.zip(ex_array, ex_array) == [a: :a, b: :b, c: :c]
      assert Enum.zip(ex_array, 1..2) == [a: 1, b: 2]
      assert Enum.zip(1..5, ex_array) == [{1, :a}, {2, :b}, {3, :c}]
      assert ex_array |> Stream.zip([1, 2, 3]) |> Stream.take(2) |> Enum.to_list() == [a: 1, b: 2]
    end

    test "with a large array crossing the index-walk boundary" do
      list = Enum.to_list(1..1_000)
      ex_array = ExArray.from_list(list)

      assert Enum.to_list(ex_array) == list
      assert Enum.take(ex_array, 5) == [1, 2, 3, 4, 5]
      assert Enum.take(ex_array, 100) == Enum.take(list, 100)
      assert Enum.find(ex_array, &(&1 == 500)) == 500
      assert Enum.zip(ex_array, ex_array) == Enum.zip(list, list)
      assert Enum.zip(ex_array, 1..40) == Enum.zip(list, 1..40)
      assert Enum.member?(ex_array, 1_000)
      refute Enum.member?(ex_array, 1_001)
    end

    test "with an empty array" do
      assert Enum.to_list(ExArray.new()) == []
      assert Enum.zip(ExArray.new(), [1]) == []
    end
  end
end
