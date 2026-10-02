# Upgrading

## Upgrading from v1.x to v2.0

Update the dependency in your `mix.exs`:

```elixir
def deps do
  [
    {:ex_array, "~> 2.0"}
  ]
end
```

Then go through the following changes. The first two are the most likely to
affect your code.

### `is_array/1` and `is_fix/1` were renamed

Following the Elixir convention of reserving the `is_` prefix for guards, the
predicates were renamed. The old names were removed, so your code will not
compile until they are replaced:

| v1.x                   | v2.0                  |
| ---------------------- | --------------------- |
| `ExArray.is_array(x)`  | `ExArray.array?(x)`   |
| `ExArray.is_fix(arr)`  | `ExArray.fixed?(arr)` |

A search and replace is enough:

```shell
grep -rlE 'ExArray\.is_(array|fix)\(' lib test \
  | xargs sed -i.bak -E 's/ExArray\.is_array\(/ExArray.array?(/g; s/ExArray\.is_fix\(/ExArray.fixed?(/g'
```

If you aliased the module, also search for `is_array(` and `is_fix(` without
the `ExArray.` prefix.

### `Access` is based on the bounds of the array

In v1.x, an entry holding the array's default value was considered missing by
`Access`, and indexes out of the bounds of a fixed-size array raised an
`ArgumentError`. An `:array` cannot tell an unset entry from an entry
explicitly set to the default value, so this was both lossy and inconsistent
with `ExArray.get/2` whenever the default value was not `nil`.

In v2.0, an index exists when `0 <= index < ExArray.size(arr)`, whatever the
value of its entry, like an index in a list:

```elixir
arr = ExArray.from_list([1, 0, 3], 0)

# v1.x
arr[1]                         #=> nil
Access.fetch(arr, 1)           #=> :error
Access.fetch(arr, 10)          #=> :error
Access.fetch(ExArray.new(3), 10) #=> ** (ArgumentError)

# v2.0
arr[1]                         #=> 0
Access.fetch(arr, 1)           #=> {:ok, 0}
Access.fetch(arr, 10)          #=> :error
Access.fetch(ExArray.new(3), 10) #=> :error
```

What to check in your code:

- **`arr[index]`, `get_in/2` and `Access.get/3` with a default value other
  than `nil`.** Entries holding the default value now return it instead of
  `nil` (or instead of the default given to `Access.get/3`). If you relied on
  `nil` to detect entries that were never set, compare against the default
  value explicitly:

  ```elixir
  # v1.x
  if arr[index] == nil, do: ...

  # v2.0
  if ExArray.get(arr, index) === ExArray.default(arr), do: ...
  ```

- **`Access.fetch/2` results.** `:error` now means "out of bounds" and no
  longer "holds the default value". Use the comparison above to keep the old
  meaning.

- **Code rescuing `ArgumentError` from `Access`.** `Access.fetch/2`,
  `arr[index]`, `get_in/2` and `pop_in/2` no longer raise for indexes out of
  bounds, negative indexes or non-integer keys: they return `:error` or `nil`.
  `ExArray.get/2` still raises for invalid indexes, so use it if you want an
  error to be raised.

- **`Access.pop/2` and `pop_in/2`.** For an index in bounds, the entry is
  reset to the default value and its value is returned, even if it already
  held the default value (the array is then returned unchanged). For any
  other index, `{nil, arr}` is returned instead of raising.

- **`Access.get_and_update/3`, `update_in/2` and `get_and_update_in/3`.** For
  an index out of bounds, the function now receives `nil` instead of the
  array's default value. As before, updating such an index grows an
  extendible array and raises for a fixed-size one. Returning `:pop` from the
  function is now supported.

### `equal?/2` compares the default value and the fixedness

Two arrays with the same entries are no longer equal when their default value
or fixedness differ:

```elixir
ExArray.equal?(ExArray.from_list([nil], nil), ExArray.from_list([nil], 0))
#=> v1.x: true, v2.0: false

ExArray.equal?(ExArray.new(1), ExArray.from_list([nil]))
#=> v1.x: true, v2.0: false
```

To compare only the entries, as in v1.x:

```elixir
ExArray.to_list(arr1) === ExArray.to_list(arr2)
```

### Collecting into a fixed-size array

Collecting into a fixed-size array always raised, since the elements are
appended after its last entry. The `ArgumentError` now has an explanatory
message. Make the array extendible first, and fix it again if needed:

```elixir
arr |> ExArray.relax() |> then(&Enum.into(values, &1)) |> ExArray.fix()
```
