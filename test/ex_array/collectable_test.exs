defmodule ExArray.CollectableTest do
  use ExUnit.Case, async: true

  test "returns an ExArray" do
    list = ~w[a b c d e f]a
    subject = Enum.into(list, ExArray.new(), & &1)

    assert ExArray.is_array(subject)
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
end
