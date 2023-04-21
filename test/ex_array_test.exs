defmodule ExArrayTest do
  use ExUnit.Case, async: true

  describe "new/0" do
    test "returns an ExArray struct with default options" do
      subject = ExArray.new()

      assert %ExArray{} = subject
      refute ExArray.is_fix(subject)
      assert ExArray.size(subject) == 0
      assert ExArray.default(subject) |> is_nil()
    end
  end

  describe "new/1" do
    test "with size return an ExArray struct" do
      subject = ExArray.new(5)

      assert %ExArray{} = subject
      assert ExArray.is_fix(subject)
      assert ExArray.size(subject) == 5
      assert ExArray.default(subject) |> is_nil()
    end

    test "with size option return an ExArray struct" do
      subject = ExArray.new(size: 5)

      assert %ExArray{} = subject
      assert ExArray.is_fix(subject)
      assert ExArray.size(subject) == 5
      assert ExArray.default(subject) |> is_nil()
    end

    test "with fixed option return an ExArray struct" do
      subject = ExArray.new(fixed: true)

      assert %ExArray{} = subject
      assert ExArray.is_fix(subject)
      assert ExArray.size(subject) == 0
      assert ExArray.default(subject) |> is_nil()
    end

    test "with default option return an ExArray struct" do
      subject = ExArray.new(default: 42)

      assert %ExArray{} = subject
      refute ExArray.is_fix(subject)
      assert ExArray.size(subject) == 0
      assert ExArray.default(subject) == 42
    end

    test "with combined options return an ExArray struct" do
      subject = ExArray.new(size: 5, default: 42, fixed: true)

      assert %ExArray{} = subject
      assert ExArray.is_fix(subject)
      assert ExArray.size(subject) == 5
      assert ExArray.default(subject) == 42
    end

    test "with negative size option raises an error" do
      assert_raise ArgumentError, fn ->
        ExArray.new(size: -5, default: 42, fixed: true)
      end
    end

    test "with unknown option raises an error" do
      assert_raise ArgumentError, fn ->
        ExArray.new(size: 5, default: 42, unkwnon: true)
      end
    end
  end

  describe "is_array/1" do
    test "with ExArray returns a boolean" do
      subject = ExArray.new()

      assert ExArray.is_array(subject)
    end

    test "with List returns a boolean" do
      subject = []

      refute ExArray.is_array(subject)
    end

    test "with Map returns a boolean" do
      subject = []

      refute ExArray.is_array(subject)
    end

    test "with String returns a boolean" do
      subject = []

      refute ExArray.is_array(subject)
    end
  end

  describe "is_fix/1" do
    test "with fixed ExArray returns a boolean" do
      subject = ExArray.new(fixed: false)

      refute ExArray.is_fix(subject)
    end

    test "with non-fixed ExArray returns a boolean" do
      subject = ExArray.new(fixed: true)

      assert ExArray.is_fix(subject)
    end

    test "with non-ExArray returns an error" do
      assert_raise FunctionClauseError, fn ->
        ExArray.is_fix(%{})
      end
    end
  end

  describe "size/1" do
    test "with empty ExArray returns an integer" do
      subject = ExArray.new(0)

      assert ExArray.size(subject) == 0
    end

    test "with non-empty ExArray returns an integer" do
      subject = ExArray.new(5) |> ExArray.set(1, "1")

      assert ExArray.size(subject) == 5
    end

    test "with non-ExArray returns an error" do
      assert_raise FunctionClauseError, fn ->
        ExArray.size([])
      end
    end
  end

  describe "sparse_size/1" do
    test "with empty ExArray returns an integer" do
      subject = ExArray.new(0)

      assert ExArray.sparse_size(subject) == 0
    end

    test "with non-empty ExArray returns an integer" do
      subject = ExArray.new(5) |> ExArray.set(1, "1")

      assert ExArray.sparse_size(subject) == 2
    end

    test "with non-ExArray returns an error" do
      assert_raise FunctionClauseError, fn ->
        ExArray.sparse_size([])
      end
    end
  end

  describe "default/1" do
    test "with ExArray returns nil" do
      subject = ExArray.new()

      assert subject |> ExArray.default() |> is_nil()
    end

    test "with non-default ExArray returns a value" do
      subject = ExArray.new(default: -1)

      assert ExArray.default(subject) == -1
    end

    test "with non-ExArray returns an error" do
      assert_raise FunctionClauseError, fn ->
        ExArray.default([])
      end
    end
  end

  describe "get/2" do
    test "with empty ExArray returns value at index" do
      subject = ExArray.new(5)

      assert subject |> ExArray.get(0) |> is_nil()
    end

    test "with non-empty ExArray returns value at index" do
      subject = ExArray.new(5) |> ExArray.set(0, "0")

      assert ExArray.get(subject, 0) == "0"
    end

    test "with empty ExArray and outbound index returns default" do
      subject = ExArray.new()

      assert subject |> ExArray.get(100) |> is_nil()
    end

    test "with empty fixed ExArray and outbound index raises an error" do
      subject = ExArray.new(fixed: true)

      assert_raise ArgumentError, fn ->
        ExArray.get(subject, 100)
      end
    end

    test "with non-ExArray returns an error" do
      assert_raise FunctionClauseError, fn ->
        ExArray.get([], 100)
      end
    end
  end

  describe "set/3" do
    test "with 0 sized ExArray returns an ExArray" do
      subject = ExArray.new() |> ExArray.set(0, "0")

      assert %ExArray{} = subject
      assert ExArray.get(subject, 0) == "0"
    end

    test "with sized ExArray returns an ExArray" do
      subject = ExArray.new(5) |> ExArray.set(0, "0")

      assert ExArray.get(subject, 0) == "0"
    end

    test "with sized ExArray and outbound index raises an error" do
      assert_raise ArgumentError, fn ->
        ExArray.new(5) |> ExArray.set(5, "0")
      end
    end

    test "with negative index raises an error" do
      assert_raise ArgumentError, fn ->
        ExArray.new() |> ExArray.set(-1, "0")
      end
    end

    test "with non-ExArray returns an error" do
      assert_raise FunctionClauseError, fn ->
        ExArray.get([], 100)
      end
    end
  end

  describe "equal?/2" do
    test "returns true if the same lists" do
      ex_array1 = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      ex_array2 = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

      assert ExArray.equal?(ex_array1, ex_array2)
    end

    test "returns true if different lists" do
      ex_array1 = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      ex_array2 = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "4")

      refute ExArray.equal?(ex_array1, ex_array2)
    end
  end

  describe "fix/1" do
    test "returns an ExArray" do
      subject = ExArray.new() |> ExArray.set(0, "0")

      refute ExArray.is_fix(subject)
      assert %ExArray{} = subject = ExArray.fix(subject)
      assert ExArray.is_fix(subject)
    end

    test "with fixed ExArray returns an ExArray" do
      subject = ExArray.new(fixed: true, size: 1) |> ExArray.set(0, "0")

      assert ExArray.is_fix(subject)
      assert %ExArray{} = subject = ExArray.fix(subject)
      assert ExArray.is_fix(subject)
    end
  end

  describe "relax/1" do
    test "returns an ExArray" do
      subject = ExArray.new() |> ExArray.set(0, "0")

      refute ExArray.is_fix(subject)
      assert %ExArray{} = subject = ExArray.relax(subject)
      refute ExArray.is_fix(subject)
    end

    test "with fixed ExArray returns an ExArray" do
      subject = ExArray.new(fixed: true, size: 1) |> ExArray.set(0, "0")

      assert ExArray.is_fix(subject)
      assert %ExArray{} = subject = ExArray.relax(subject)
      refute ExArray.is_fix(subject)
    end
  end

  describe "reset/2" do
    test "with default as nil returns an ExArray" do
      subject = ExArray.new() |> ExArray.set(0, "0")

      assert ExArray.get(subject, 0) == "0"
      assert %ExArray{} = subject = ExArray.reset(subject, 0)
      assert subject |> ExArray.get(0) |> is_nil()
    end

    test "with default as -1 returns an ExArray" do
      subject = ExArray.new(default: -1) |> ExArray.set(0, "0")

      assert ExArray.get(subject, 0) == "0"
      assert %ExArray{} = subject = ExArray.reset(subject, 0)
      assert ExArray.get(subject, 0) == -1
    end
  end

  describe "resize/1" do
    test "returns an ExArray" do
      subject = ExArray.new(5) |> ExArray.set(1, "0")

      assert ExArray.size(subject) == 5
      assert %ExArray{} = subject = ExArray.resize(subject)
      assert ExArray.size(subject) == 2
    end
  end

  describe "resize/2" do
    test "returns an ExArray" do
      subject = ExArray.new(5) |> ExArray.set(1, "0")

      assert ExArray.size(subject) == 5
      assert %ExArray{} = subject = ExArray.resize(subject, 3)
      assert ExArray.size(subject) == 3
    end
  end

  describe "from_erlang_array/1" do
    test "returns an ExArray" do
      erl_array = :array.from_list(["0", nil, "2", nil, "4"])
      ex_array = ExArray.from_erlang_array(erl_array)

      assert ExArray.is_array(ex_array)
      assert ExArray.to_list(ex_array) == ["0", nil, "2", nil, "4"]
    end
  end

  describe "from_list/1" do
    test "returns an ExArray" do
      list = ["0", nil, "2", nil, "4"]
      ex_array = ExArray.from_list(list)

      assert ExArray.is_array(ex_array)
      assert ExArray.to_list(ex_array) == ["0", nil, "2", nil, "4"]
    end
  end

  describe "from_orddict/1" do
    test "returns an ExArray" do
      orddict = [{0, "0"}, {2, "2"}, {4, "4"}]
      ex_array = ExArray.from_orddict(orddict)

      assert ExArray.is_array(ex_array)
      assert ExArray.to_list(ex_array) == ["0", nil, "2", nil, "4"]
    end
  end

  describe "to_erlang_array/1" do
    test "returns an :array.array()" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      subject = ExArray.to_erlang_array(ex_array)

      assert :array.is_array(subject)
      assert :array.to_list(subject) == [nil, "1", nil, "3", nil]
    end
  end

  describe "to_list/1" do
    test "returns a list" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      subject = ExArray.to_list(ex_array)

      assert is_list(subject)
      assert subject == [nil, "1", nil, "3", nil]
    end
  end

  describe "sparse_to_list/1" do
    test "returns an a list without defaults" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      subject = ExArray.sparse_to_list(ex_array)

      assert is_list(subject)
      assert subject == ["1", "3"]
    end
  end

  describe "to_orddict/1" do
    test "returns an ordered dictionary" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      subject = ExArray.to_orddict(ex_array)

      assert subject == [{0, nil}, {1, "1"}, {2, nil}, {3, "3"}, {4, nil}]
    end
  end

  describe "sparse_to_orddict/1" do
    test "returns an ordered dictionary" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      subject = ExArray.sparse_to_orddict(ex_array)

      assert subject == [{1, "1"}, {3, "3"}]
    end
  end

  describe "map/2" do
    test "returns an ExArray" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      subject = ExArray.map(ex_array, fn index, value -> {index, value} end)

      assert ExArray.is_array(subject)
      assert ExArray.to_list(subject) == [{0, nil}, {1, "1"}, {2, nil}, {3, "3"}, {4, nil}]
    end
  end

  describe "sparse_map/2" do
    test "returns an ExArray" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      subject = ExArray.sparse_map(ex_array, fn index, value -> {index, value} end)

      assert ExArray.is_array(subject)
      assert ExArray.to_list(subject) == [nil, {1, "1"}, nil, {3, "3"}, nil]
    end
  end

  describe "foldl/3" do
    test "returns a list" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      subject = ExArray.foldl(ex_array, [], fn index, value, acc -> [{index, value} | acc] end)

      assert subject == [{4, nil}, {3, "3"}, {2, nil}, {1, "1"}, {0, nil}]
    end
  end

  describe "sparse_foldl/3" do
    test "returns a list" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      subject = ExArray.sparse_foldl(ex_array, [], fn index, value, acc -> [{index, value} | acc] end)

      assert subject == [{3, "3"}, {1, "1"}]
    end
  end

  describe "foldr/3" do
    test "returns a list" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      subject = ExArray.foldr(ex_array, [], fn index, value, acc -> [{index, value} | acc] end)

      assert subject == [{0, nil}, {1, "1"}, {2, nil}, {3, "3"}, {4, nil}]
    end
  end

  describe "sparse_foldr/3" do
    test "returns a list" do
      ex_array = ExArray.new(size: 5) |> ExArray.set(1, "1") |> ExArray.set(3, "3")
      subject = ExArray.sparse_foldr(ex_array, [], fn index, value, acc -> [{index, value} | acc] end)

      assert subject == [{1, "1"}, {3, "3"}]
    end
  end
end
