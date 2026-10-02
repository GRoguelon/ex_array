# ExArray

A wrapper module for Erlang's array.

## When to use `ExArray` instead of a `List`

Elixir lists are singly linked lists: adding or removing an element at the
front is cheap, but reaching the element at index `i` means walking the `i`
elements before it, and updating it means copying them. `ExArray` wraps
Erlang's [`:array`](https://www.erlang.org/doc/apps/stdlib/array.html), a
functional tree with a branching factor of 10: reading or updating any index
only visits a handful of nodes, whatever the size of the array.

Use a **`List`** (the default choice) when you:

- process elements sequentially with `Enum`, `Stream` or recursion and
  pattern matching;
- build a collection by prepending elements (`[elem | list]`);
- work with small collections or data you rarely access by index.

Use an **`ExArray`** when you:

- read or update elements by index in large collections, e.g. dynamic
  programming tables, grids, buffers or lookup tables;
- grow a collection by setting indexes beyond its end;
- store sparse data, where unset entries return a `default` value and
  `sparse_*` functions skip them;
- need a fixed-size collection that rejects out-of-bounds writes.

Indicative timings on a 1,000,000-element collection:

| Operation              | `List`  | `ExArray` |
| ---------------------- | ------- | --------- |
| Read at middle index   | ~1 ms   | ~60 ns    |
| Update at middle index | ~19 ms  | ~140 ns   |
| Append one element     | ~18 ms  | ~720 ns   |
| Prepend one element    | ~40 ns  | n/a       |
| Sum all elements       | ~1.8 ms | ~16 ms    |
| Memory per element     | 16 B    | ~9 B      |

Other options to consider:

- **Tuples** give constant-time reads (`elem/2`), but every update copies the
  whole tuple: use them for small or read-only collections.
- **Maps with integer keys** have reads and updates as fast as `ExArray` or
  faster, but use about three times as much memory. Also, maps with more than
  32 keys do not keep their keys ordered, and they have no notion of size
  bounds or default values.
- **[`:atomics`](https://www.erlang.org/doc/apps/erts/atomics.html)** and
  **[`:counters`](https://www.erlang.org/doc/apps/erts/counters.html)** provide
  mutable arrays of integers, shared between processes.

## Installation

Requires Elixir v1.14+:

```elixir
def deps do
  [
    {:ex_array, "~> 2.0"}
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

arr |> ExArray.relax() |> ExArray.fixed?()
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

An index exists when it is within the bounds of the array
(`0 <= index < ExArray.size(arr)`), whatever the value of its entry: `arr[index]`
returns the same value as `ExArray.get/2`, including entries holding the
default value. Indexes out of bounds, negative indexes and non-integer keys
behave like missing keys in a map: they return `nil` and never raise.

```elixir
arr = ExArray.from_list([1, 0, 3], 0)

arr[1]
#=> 0

arr[10]
#=> nil

Access.fetch(arr, 10)
#=> :error
```

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

Like lists and bitstrings, `Enum.into/2` and `for` comprehensions with `:into`
append new values **after** the existing entries, preserving the target array's
`default` value:

```elixir
Enum.into([4, 5], ExArray.from_list([1, 2, 3]))
#=> #ExArray<[1, 2, 3, 4, 5], fixed=false, default=nil>

for x <- 1..3, into: ExArray.new(default: 0), do: x * 2
#=> #ExArray<[2, 4, 6], fixed=false, default=0>
```

A fixed-size array cannot grow, so collecting any value into it raises an
`ArgumentError`; call `ExArray.relax/1` first.

## Acknowledgments

This package is a fork of [takscape/elixir-array](https://github.com/takscape/elixir-array). The latest commit was in 2014 and the compilation was broken with recent versions of Elixir.
