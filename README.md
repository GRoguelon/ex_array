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

### Convertions

```elixir
arr = ExArray.new(3) |> ExArray.set(1, "Hello")

ExArray.to_list(arr)
#=> [nil, "5", nil]

ExArray.sparse_to_list(arr)
#=> ["Hello"]

ExArray.to_orddict(arr)
#=> [{0, nil}, {1, "Hello"}, {2, nil}]

ExArray.sparse_to_orddict(arr)
#=> [{1, "Hello"}]
```

## Acknowledgments

This package is a fork of [takscape/elixir-array](https://github.com/takscape/elixir-array). The latest commit was in 2014 and the compilation was broken with recent versions of Elixir.
