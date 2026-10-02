defmodule ExArray.CollectableTest do
  use ExUnit.Case, async: true

  test "returns an ExArray" do
    list = ~w[a b c d e f]a
    subject = Enum.into(list, ExArray.new(), & &1)

    assert ExArray.array?(subject)
    assert ExArray.to_list(subject) == list
  end

  test "appends new values after existing entries" do
    initial = ExArray.from_list([:a, :b, :c])
    subject = Enum.into([:d, :e], initial, & &1)

    assert ExArray.to_list(subject) == [:a, :b, :c, :d, :e]
  end

  test "preserves the default value of the original array" do
    initial = ExArray.new(default: 0)
    subject = Enum.into([1, 2, 3], initial, & &1)

    assert ExArray.default(subject) == 0
    assert ExArray.to_list(subject) == [1, 2, 3]
  end

  test "preserves the default value of a non-empty original array" do
    initial = ExArray.from_list([:a], :x)
    subject = Enum.into([:b], initial)

    assert ExArray.default(subject) == :x
    assert ExArray.to_list(subject) == [:a, :b]
  end

  test "returns the original array when nothing is collected" do
    for initial <- [
          ExArray.new(),
          ExArray.new(default: 0),
          ExArray.from_list([1]),
          ExArray.new(3)
        ] do
      assert ExArray.equal?(Enum.into([], initial), initial)
    end
  end

  test "raises when collecting into a fixed-size array" do
    assert_raise ArgumentError, ~r/fixed-size/, fn -> Enum.into([1], ExArray.new(3)) end
    assert_raise ArgumentError, ~r/fixed-size/, fn -> Enum.into([1], ExArray.new(:fixed)) end
  end

  test "works with comprehensions" do
    subject = for x <- 1..3, into: ExArray.from_list([0]), do: x * 2

    assert ExArray.to_list(subject) == [0, 2, 4, 6]
  end

  test "halts without leaking the accumulator" do
    for initial <- [ExArray.new(), ExArray.from_list([1]), ExArray.new(1)] do
      {acc, collector} = Collectable.into(initial)

      assert collector.(acc, :halt) == :ok
    end
  end
end
