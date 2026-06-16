# ExArray

A wrapper module for Erlang's array.

## Installation

Requires Elixir v1.14+:

```elixir
def deps do
  [
    {:ex_array, "~> 0.1.3"}
  ]
end
```

Documentation can be found at: <https://hexdocs.pm/ex_array>.

## Usage

### Initialization

Without options, `ExArray` fallbacks on:
* `size`: 0
* `default`: `nil`
* `fixed`: `false`

```elixir
ExArray.new()
#=> #ExArray<[], fixed=false, default=nil>

ExArray.new(5)
#=> #ExArray<[nil, nil, nil, nil, nil], fixed=true, default=nil>
```

You can provide options to change defaults:
```elixir
ExArray.new(size: 5, default: 0, fixed: false)
#=> #ExArray<[0, 0, 0, 0, 0], fixed=false, default=0>
```

*Note:* When you specify a `size`, the array is automatically `fixed`.

### Setter

```elixir
arr = ExArray.new(size: 5, default: 0, fixed: false)

arr = ExArray.set(arr, 1, "Hello")
#=> #ExArray<[0, "Hello", 0, 0, 0], fixed=false, default=0>

ExArray.reset(arr, 1)
#=> #ExArray<[0, 0, 0, 0, 0], fixed=false, default=0>
```

### Getter

```elixir
arr = ExArray.new() |> ExArray.set(1, "Hello")

ExArray.get(arr, 0)
#=> nil

ExArray.get(arr, 1)
#=> "Hello"

ExArray.size(arr)
#=> 2
```

### Conversions

```elixir
arr = ExArray.new(3) |> ExArray.set(1, "Hello")

ExArray.to_list(arr)
#=> [nil, "Hello", nil]

ExArray.sparse_to_list(arr)
#=> ["Hello"]

ExArray.to_orddict(arr)
#=> [{0, nil}, {1, "Hello"}, {2, nil}]

ExArray.sparse_to_orddict(arr)
#=> [{1, "Hello"}]
```

You can also build an `ExArray` from existing data, or unwrap it back to an
Erlang `:array`:

```elixir
ExArray.from_list(["a", "b", "c"])
#=> #ExArray<["a", "b", "c"], fixed=false, default=nil>

ExArray.from_orddict([{0, "a"}, {2, "c"}])
#=> #ExArray<["a", nil, "c"], fixed=false, default=nil>

arr = ExArray.from_list([1, 2, 3])
ExArray.to_erlang_array(arr)
#=> {:array, 3, 10, nil, {1, 2, 3, nil, nil, nil, nil, nil, nil, nil}}
```

### Iteration

`ExArray` exposes the same `map`/`foldl`/`foldr` helpers as Erlang's `:array`,
plus their `sparse_*` counterparts that skip default-valued entries:

```elixir
arr = ExArray.new(size: 4) |> ExArray.set(1, "1") |> ExArray.set(3, "3")

ExArray.map(arr, fn index, value -> {index, value} end)
#=> #ExArray<[{0, nil}, {1, "1"}, {2, nil}, {3, "3"}], fixed=true, default=nil>

ExArray.sparse_foldl(arr, [], fn index, value, acc -> [{index, value} | acc] end)
#=> [{3, "3"}, {1, "1"}]
```

### Resizing and fixedness

```elixir
arr = ExArray.new(5) |> ExArray.set(1, "1")

arr |> ExArray.relax() |> ExArray.is_fix()
#=> false

arr |> ExArray.resize() |> ExArray.size()
#=> 2

ExArray.equal?(ExArray.from_list([1, 2]), ExArray.from_list([1, 2]))
#=> true
```

## Protocols

`ExArray` implements the `Access`, `Enumerable`, `Collectable`, and `Inspect`
protocols, so it works with Elixir's standard tooling.

### Access

```elixir
arr = ExArray.from_list(["a", "b", "c"])

arr[1]
#=> "b"

get_in(arr, [0])
#=> "a"

{previous, arr} = pop_in(arr, [1])
#=> {"b", #ExArray<["a", nil, "c"], fixed=false, default=nil>}

update_in(arr, [0], &String.upcase/1)
#=> #ExArray<["A", nil, "c"], fixed=false, default=nil>
```

`Access.fetch/2` returns `:error` when the slot still holds the array's
default value; explicitly stored values (including `nil` and `false`) are
returned as `{:ok, value}`.

### Enumerable

```elixir
arr = ExArray.from_list([1, 2, 3, 4, 5])

Enum.count(arr)
#=> 5

Enum.map(arr, &(&1 * 2))
#=> [2, 4, 6, 8, 10]

Enum.slice(arr, 1..3)
#=> [2, 3, 4]
```

### Collectable

`Enum.into/3` appends new values **after** the existing entries, preserving the
target array's `default` and `fixed` settings:

```elixir
Enum.into([4, 5], ExArray.from_list([1, 2, 3]))
#=> #ExArray<[1, 2, 3, 4, 5], fixed=false, default=nil>
```

## Acknowledgments

This package is a fork of [takscape/elixir-array](https://github.com/takscape/elixir-array). The latest commit was in 2014 and the compilation was broken with recent versions of Elixir.
