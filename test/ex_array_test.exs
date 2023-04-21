defmodule ExArrayTest do
  use ExUnit.Case, async: true

  test "new/0" do
    a = ExArray.new()

    assert true == ExArray.is_array(a)
    assert false == ExArray.is_fix(a)
    assert nil == ExArray.default(a)

    assert nil == ExArray.get(a, 0)
    assert 0 == ExArray.size(a)
    a = ExArray.set(a, 0, 1)
    assert 1 == ExArray.get(a, 0)
    assert 1 == ExArray.size(a)
  end

  test "new/1, size specified" do
    a = ExArray.new(10)

    assert true == ExArray.is_array(a)
    assert true == ExArray.is_fix(a)
    assert nil == ExArray.default(a)
    assert 10 == ExArray.size(a)

    assert nil == ExArray.get(a, 0)

    assert nil == ExArray.get(a, 9)

    assert_raise ArgumentError, fn ->
      ExArray.get(a, 10)
    end

    a = ExArray.set(a, 0, 1)
    assert 1 == ExArray.get(a, 0)

    a = ExArray.set(a, 9, 9)
    assert 9 == ExArray.get(a, 9)

    assert_raise ArgumentError, fn ->
      ExArray.set(a, 10, 10)
    end
  end

  test "new/1, negative size" do
    # This is not an error
    ExArray.new(0)

    assert_raise ArgumentError, fn ->
      ExArray.new(-1)
    end
  end

  test "new/1, fixed" do
    a = ExArray.new(:fixed)

    assert true == ExArray.is_array(a)
    assert true == ExArray.is_fix(a)
    assert nil == ExArray.default(a)
  end

  test "new/1, default value specified" do
    a = ExArray.new(default: -1)

    assert true == ExArray.is_array(a)
    assert false == ExArray.is_fix(a)
    assert -1 == ExArray.default(a)
    assert -1 == ExArray.get(a, 0)
  end

  test "default" do
    a = ExArray.new(default: "foo")
    assert "foo" == ExArray.default(a)

    a2 = ExArray.new()
    assert nil == ExArray.default(a2)
  end

  test "equal?" do
    assert ExArray.equal?(ExArray.from_list([1, 2, 3]), ExArray.from_list([1, 2, 3]))
    assert ExArray.equal?(ExArray.from_list([1, :foo, "bar"]), ExArray.from_list([1, :foo, "bar"]))
    assert ExArray.equal?(ExArray.new(), ExArray.new())
    assert ExArray.equal?(ExArray.new(10), ExArray.new() |> ExArray.set(9, nil))
    assert false == ExArray.equal?(ExArray.from_list([1, 2, 3]), ExArray.from_list([1, 2, 3, 4]))
    assert false == ExArray.equal?(ExArray.from_list([2, 2, 3]), ExArray.from_list([1, 2, 3]))
    assert false == ExArray.equal?(ExArray.new(), ExArray.from_list(["a", "b", "c"]))
  end

  test "fix" do
    a = ExArray.new()
    a = ExArray.set(a, 100, 0)

    a = ExArray.fix(a)

    assert_raise ArgumentError, fn ->
      ExArray.set(a, 101, 0)
    end
  end

  test "foldl" do
    a = ExArray.from_list(["a", "b", "c"])

    res =
      ExArray.foldl(a, "foo", fn idx, elm, acc ->
        case idx do
          0 -> assert "a" == elm
          1 -> assert "b" == elm
          2 -> assert "c" == elm
          _ -> assert false
        end

        acc <> elm
      end)

    assert "fooabc" == res

    assert_raise ArgumentError, fn ->
      ExArray.foldl(a, "foo", "bar")
    end
  end

  test "foldr" do
    a = ExArray.from_list(["a", "b", "c"])

    res =
      ExArray.foldr(a, "foo", fn idx, elm, acc ->
        case idx do
          0 -> assert "a" == elm
          1 -> assert "b" == elm
          2 -> assert "c" == elm
          _ -> assert false
        end

        acc <> elm
      end)

    assert "foocba" == res

    assert_raise ArgumentError, fn ->
      ExArray.foldr(a, "foo", "bar")
    end
  end

  test "from_list/1" do
    a = ExArray.from_list([1, 2, 3])

    assert true == ExArray.is_array(a)
    assert false == ExArray.is_fix(a)
    assert nil == ExArray.default(a)
    assert 3 == ExArray.size(a)

    assert 1 == ExArray.get(a, 0)
    assert 2 == ExArray.get(a, 1)
    assert 3 == ExArray.get(a, 2)
  end

  test "from_list/2" do
    a = ExArray.from_list([3, 2, 1], :foo)

    assert true == ExArray.is_array(a)
    assert false == ExArray.is_fix(a)
    assert :foo == ExArray.default(a)
    assert 3 == ExArray.size(a)

    assert 3 == ExArray.get(a, 0)
    assert 2 == ExArray.get(a, 1)
    assert 1 == ExArray.get(a, 2)
  end

  test "from_orddict/1" do
    a = ExArray.from_orddict([{1, "a"}, {3, "c"}, {4, "b"}])

    assert true == ExArray.is_array(a)
    assert false == ExArray.is_fix(a)
    assert nil == ExArray.default(a)
    assert 5 == ExArray.size(a)

    assert nil == ExArray.get(a, 0)
    assert "a" == ExArray.get(a, 1)
    assert nil == ExArray.get(a, 2)
    assert "c" == ExArray.get(a, 3)
    assert "b" == ExArray.get(a, 4)
    assert nil == ExArray.get(a, 5)

    assert_raise ArgumentError, fn ->
      # unordered
      ExArray.from_orddict([{1, "a"}, {4, "b"}, {3, "c"}])
    end
  end

  test "from_orddict/2" do
    a = ExArray.from_orddict([{1, "a"}, {3, "c"}, {4, "b"}], :foo)

    assert true == ExArray.is_array(a)
    assert false == ExArray.is_fix(a)
    assert :foo == ExArray.default(a)
    assert 5 == ExArray.size(a)

    assert :foo == ExArray.get(a, 0)
    assert "a" == ExArray.get(a, 1)
    assert :foo == ExArray.get(a, 2)
    assert "c" == ExArray.get(a, 3)
    assert "b" == ExArray.get(a, 4)
    assert :foo == ExArray.get(a, 5)

    assert_raise ArgumentError, fn ->
      # unordered
      ExArray.from_orddict([{1, "a"}, {4, "b"}, {3, "c"}], :foo)
    end
  end

  test "from_erlang_array" do
    erl_arr = :array.new()
    erl_arr = :array.set(0, 1, erl_arr)
    erl_arr = :array.set(1, 2, erl_arr)
    erl_arr = :array.set(2, 3, erl_arr)

    a = ExArray.from_erlang_array(erl_arr)
    assert true == ExArray.is_array(a)
    assert :array.size(erl_arr) == ExArray.size(a)
    assert :array.is_fix(erl_arr) == ExArray.is_fix(a)
    assert :array.default(erl_arr) == ExArray.default(a)
    assert 1 == ExArray.get(a, 0)
    assert 2 == ExArray.get(a, 1)
    assert 3 == ExArray.get(a, 2)

    assert_raise ArgumentError, fn ->
      ExArray.from_erlang_array([1, 2, 3])
    end
  end

  test "is_array" do
    assert true == ExArray.is_array(ExArray.new())
    assert false == ExArray.is_array(0)
    assert false == ExArray.is_array(nil)
    assert false == ExArray.is_array("foo")
    assert false == ExArray.is_array(:array.new())
  end

  test "is_fix" do
    assert true == ExArray.is_fix(ExArray.new(:fixed))
    assert false == ExArray.is_fix(ExArray.new(fixed: false))
  end

  test "map" do
    a = ExArray.from_list([1, 2, 3])

    a2 =
      ExArray.map(a, fn idx, elm ->
        case idx do
          0 -> assert 1 == elm
          1 -> assert 2 == elm
          2 -> assert 3 == elm
          _ -> assert false
        end

        2 * elm
      end)

    assert [2, 4, 6] == ExArray.to_list(a2)

    assert_raise ArgumentError, fn ->
      ExArray.map(a, "foo")
    end
  end

  test "relax" do
    a = ExArray.new(:fixed)
    assert true == ExArray.is_fix(a)

    a = ExArray.relax(a)
    assert false == ExArray.is_fix(a)
  end

  test "reset" do
    a = ExArray.from_list([1, 2, 3])
    assert 2 == ExArray.get(a, 1)

    a = ExArray.reset(a, 1)
    assert nil == ExArray.get(a, 1)
  end

  test "resize/1" do
    a = ExArray.new(10)
    assert 10 == ExArray.size(a)
    assert 0 == ExArray.sparse_size(a)

    a = ExArray.set(a, 8, 1)
    assert 10 == ExArray.size(a)
    assert 9 == ExArray.sparse_size(a)

    a = ExArray.resize(a)
    assert 9 == ExArray.size(a)
    assert 9 == ExArray.sparse_size(a)
  end

  test "resize/2" do
    a = ExArray.new(size: 10, fixed: true)
    assert 10 == ExArray.size(a)

    a = ExArray.resize(a, 5)
    assert 5 == ExArray.size(a)
    assert true == ExArray.is_fix(a)
    assert false == ExArray.new(size: 10, fixed: false) |> ExArray.resize(5) |> ExArray.is_fix()

    assert_raise ArgumentError, fn ->
      ExArray.resize(ExArray.new(), -1)
    end
  end

  test "get/set" do
    a = ExArray.new()

    a = ExArray.set(a, 5, 10)
    assert nil == ExArray.get(a, 4)
    assert 10 == ExArray.get(a, 5)
    assert nil == ExArray.get(a, 6)

    a = ExArray.set(a, 0, 100)
    assert 100 == ExArray.get(a, 0)

    assert_raise ArgumentError, fn ->
      ExArray.set(a, -1, 1000)
    end

    assert_raise ArgumentError, fn ->
      ExArray.get(a, -1)
    end
  end

  test "size" do
    assert 10 == ExArray.new(size: 10) |> ExArray.size()
    assert 5 == ExArray.new(size: 5) |> ExArray.size()
    assert 6 == ExArray.new() |> ExArray.set(5, 0) |> ExArray.size()
  end

  test "sparse_foldl" do
    a = ExArray.new(size: 10, default: "x")
    a = a |> ExArray.set(2, "a") |> ExArray.set(4, "b") |> ExArray.set(6, "c")

    res =
      ExArray.sparse_foldl(a, "foo", fn idx, elm, acc ->
        case idx do
          2 -> assert "a" == elm
          4 -> assert "b" == elm
          6 -> assert "c" == elm
          _ -> assert false
        end

        acc <> elm
      end)

    assert "fooabc" == res

    assert_raise ArgumentError, fn ->
      ExArray.sparse_foldl(a, "foo", "bar")
    end
  end

  test "sparse_foldr" do
    a = ExArray.new(size: 10, default: "x")
    a = a |> ExArray.set(1, "a") |> ExArray.set(3, "b") |> ExArray.set(5, "c")

    res =
      ExArray.sparse_foldr(a, "foo", fn idx, elm, acc ->
        case idx do
          1 -> assert "a" == elm
          3 -> assert "b" == elm
          5 -> assert "c" == elm
          _ -> assert false
        end

        acc <> elm
      end)

    assert "foocba" == res

    assert_raise ArgumentError, fn ->
      ExArray.sparse_foldr(a, "foo", "bar")
    end
  end

  test "sparse_map" do
    a = ExArray.new(size: 10)
    a = a |> ExArray.set(1, 2) |> ExArray.set(3, 4) |> ExArray.set(5, 6)

    res =
      ExArray.sparse_map(a, fn idx, elm ->
        case idx do
          1 -> assert 2 == elm
          3 -> assert 4 == elm
          5 -> assert 6 == elm
          _ -> assert false
        end

        elm / 2
      end)

    Enum.each(0..9, fn idx ->
      case idx do
        1 -> assert 1 == ExArray.get(res, idx)
        3 -> assert 2 == ExArray.get(res, idx)
        5 -> assert 3 == ExArray.get(res, idx)
        _ -> assert nil == ExArray.get(res, idx)
      end
    end)

    assert_raise ArgumentError, fn ->
      ExArray.sparse_map(a, "foo")
    end
  end

  test "sparse_size" do
    a = ExArray.from_list([1, 2, 3, 4, 5])
    assert 5 == ExArray.sparse_size(a)
    a = ExArray.reset(a, 4)
    assert 4 == ExArray.sparse_size(a)
  end

  test "sparse_to_list" do
    a = ExArray.new(size: 10)
    a = a |> ExArray.set(1, 1) |> ExArray.set(3, 2) |> ExArray.set(5, 3)

    assert [1, 2, 3] == ExArray.sparse_to_list(a)
  end

  test "sparse_to_orddict" do
    a = ExArray.new(size: 10)
    a = a |> ExArray.set(2, 1) |> ExArray.set(4, 2) |> ExArray.set(6, 3)

    assert [{2, 1}, {4, 2}, {6, 3}] == ExArray.sparse_to_orddict(a)
  end

  test "to_erlang_array" do
    a = ExArray.from_list([1, 2, 3])
    ea = ExArray.to_erlang_array(a)

    assert :array.is_array(ea)
    assert 3 == :array.size(ea)
    assert 1 == :array.get(0, ea)
    assert 2 == :array.get(1, ea)
    assert 3 == :array.get(2, ea)
  end

  test "to_list" do
    a = ExArray.from_list([1, 2, 3])
    assert [1, 2, 3] == ExArray.to_list(a)
  end

  test "to_orddict" do
    a = ExArray.from_list([1, 2, 3])
    assert [{0, 1}, {1, 2}, {2, 3}] == ExArray.to_orddict(a)
  end

  test "Access.get" do
    a = ExArray.from_list([1, 2, 3])
    assert 1 == a[0]
    assert 2 == a[1]
    assert 3 == a[2]
    assert nil == a[3]
  end

  test "Access.get_and_update" do
    a = ExArray.from_list([1, 2, 3])
    {get, update} = Access.get_and_update(a, 1, fn v -> {2 * v, 100} end)
    assert 4 == get
    assert [1, 100, 3] == ExArray.to_list(update)
  end

  test "Enumerable.count" do
    a = ExArray.from_list([1, 2, 3])
    assert 3 == Enum.count(a)
  end

  test "Enumerable.member" do
    a = ExArray.from_list([1, 2, 3])
    assert Enum.member?(a, 3)
    assert false == Enum.member?(a, 4)
  end

  test "Enumerable.reduce" do
    sum = Enum.reduce(ExArray.from_list([1, 2, 3]), 0, fn x, acc -> x + acc end)
    assert 6 == sum
  end

  test "Collectable.into" do
    a = Enum.into([1, 2, 3], ExArray.new())
    assert ExArray.is_array(a)
    assert [1, 2, 3] == ExArray.to_list(a)
  end
end
