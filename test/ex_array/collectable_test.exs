defmodule ExArray.CollectableTest do
  use ExUnit.Case, async: true

  test "returns an ExArray" do
    list = ~w[a b c d e f]a
    subject = Enum.into(list, ExArray.new(), & &1)

    assert ExArray.is_array(subject)
    assert ExArray.to_list(subject) == list
  end
end
