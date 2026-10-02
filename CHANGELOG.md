# Changelog

## v2.0.0 (2026-10-02)

This release contains breaking changes, see the
[upgrade guide](UPGRADING.md#upgrading-from-v1-x-to-v2-0) for how to migrate.

### Breaking changes

- Changed `Access` to consider that an index exists when it is within the
  bounds of the array (`0 <= index < size/1`), whatever the value of its
  entry, instead of treating entries holding the default value as missing.
  `arr[index]` now always returns the same value as `get/2` for indexes in
  bounds, including when the default value is not `nil`.
  - `Access.fetch/2` returns `{:ok, value}` for every index in bounds,
    including entries holding the default value, and `:error` for any other
    index (out of bounds, negative or not an integer) instead of raising an
    `ArgumentError`.
  - `Access.pop/2` resets the entry and returns its value for every index in
    bounds, and returns `{nil, array}` for any other index instead of raising
    an `ArgumentError`.
  - `Access.get_and_update/3` passes `nil` to the function for indexes out of
    bounds. Updating such an index grows an extendible array and raises an
    `ArgumentError` for a fixed-size array, as before.
- Removed `is_array/1` and `is_fix/1`, replaced by `array?/1` and `fixed?/1`
  to follow the Elixir convention of reserving the `is_` prefix for guards.
- Changed `equal?/2` to also compare the size, the default value and the
  fixedness of the arrays. Previously, arrays with different default values
  or fixedness were considered equal when their entries were the same.
- Changed `Collectable.into/1` to raise an `ArgumentError` with an
  explanatory message as soon as an element is collected into a fixed-size
  array, instead of the bare `ArgumentError` raised by `:array.set/3`.

### Features

- Added `array?/1` and `fixed?/1`.
- Added support for a single non-list option in `new/1`, such as
  `new(:fixed)` or `new({:default, 0})`, as allowed by the `options()` type
  and the documentation. It used to raise a `FunctionClauseError`.

### Bug fixes

- Fixed `Access.get_and_update/3` raising a `MatchError` when the function
  returns `:pop`. The entry is now reset to the default value and its
  previous value returned, as `Access.pop/2` does.
- Fixed `Inspect` ignoring the inspect options (e.g. `:syntax_colors`) when
  rendering the default value.

### Performance

- Improved `Enumerable.reduce/3` to stop converting the whole array to a list
  before reducing. The first elements are visited by index, so reductions
  that halt early (`Enum.take/2`, `Enum.find/2`, `Enum.any?/2`, ...) run in
  constant time and memory instead of O(n): on a 1,000,000-element array,
  `Enum.take(arr, 10)` drops from ~7 ms to under 1 µs and from ~15 MB to
  under 1 KB of memory. Full traversals keep the speed of the list-based
  implementation.
- Improved `Inspect` to only materialize the elements that will be printed
  (honoring the `:limit` option), instead of converting the whole array to a
  list: inspecting a 1,000,000-element array drops from ~9 ms to ~26 µs.
- Improved `Collectable.into/1` when collecting into an empty extendible
  array: the values are accumulated and the array is built at once with
  `:array.from_list/2`, which is 3 to 5 times faster than setting them one by
  one.
- Simplified `Enumerable.slice/1` to always return the 3-arity `slicing_fun`,
  which is supported since Elixir 1.14, removing the compile-time Elixir
  version check.

### Documentation

- Fixed the documentation of `map/2`, `sparse_map/2`, `foldl/3`,
  `sparse_foldl/3`, `foldr/3` and `sparse_foldr/3`, which raise a
  `FunctionClauseError` (not an `ArgumentError`) when `fun` is not a function
  of the expected arity, and of `get/2`, which returns the default value for
  indexes out of bounds of extendible arrays.
- Fixed the README description of `Access` and `Collectable`, and added
  doctests for the documentation examples.
- Added an upgrade guide.
- Added a section to the README explaining when to use `ExArray` instead of a
  `List`, a tuple or a map.

### Internal

- Added `bench/run.exs` and `bench/compare.sh` to benchmark the protocol and
  `Access` implementations (run time, memory usage and reductions) with
  Benchee, and compare a git revision against the working tree.
- Added regression tests for the changes above and for halting and
  suspending reductions (`Enum.zip/2`, `Stream.zip/2`) on small and large
  arrays.
- Fixed the type warnings emitted by the test suite on Elixir v1.18+, and a
  `set/3` test that was calling `get/2`.
- Silenced the ExDoc warnings about functions referenced by past releases in
  the changelog.

## v1.0.0 (2026-06-16)

- Fixed `Access.fetch/2` and `Access.pop/2` to no longer treat stored falsy
  values (e.g. `false`, `nil`) as missing; entries are now compared against
  the array's default value instead of a truthy check.
- Improved `Collectable.into/1` to append via `:array.set/3` starting at the
  original array's `size/1`, instead of rebuilding through
  `to_list/from_list`. The original array's `default` and `fixed` attributes
  are now preserved.
- Improved `Enumerable.slice/1` to return a `slicing_fun`, so partial slices
  touch only the requested window rather than materializing the full list.
  The implementation is selected at compile time: the 2-arity form on
  Elixir 1.14–1.17, and the 3-arity form (with `step` support) on
  Elixir 1.18+, which silences the deprecation warning emitted on those
  versions.
- Replaced the soft-deprecated `unless` macro in `from_erlang_array/1` for
  forward compatibility with Elixir 1.19+.
- Fixed typespecs so `mix dialyzer` passes on Elixir 1.18 / OTP 28+. The
  hand-written `array()` opaque tuple now delegates to `:array.array/0`, and
  `orddict()` is exposed as a regular `@type` (it is a user-constructable
  list of `{index, value}` tuples, not an opaque value).
- Added a GitHub Actions workflow exercising `mix compile --warnings-as-errors`,
  `mix test`, and `mix dialyzer` across every supported Elixir 1.14–1.20 /
  OTP 24–29 combination.
- Documented the `Access`, `Enumerable`, and `Collectable` protocols in the
  README, added examples for the remaining public API, and fixed a stale
  output value and a typo (`Convertions` → `Conversions`).
- Added regression tests covering the `Access` falsy-value fix, `Collectable`
  attribute preservation, the `Enum.slice/3` `start/length` form, and stepped
  ranges (`Enum.slice(arr, 0..5//2)`) to exercise the 3-arity `slicing_fun`'s
  step path on Elixir 1.18+.

## v0.1.3 (2023-04-21)

- Improved the README.md by providing examples

## v0.1.2 (2023-04-21)

- Added tests to get full coverage
- Replaced the implementation of `ExArray.equal?/2`
- Added a clause for non `ExArray` argument for `ExArray.is_array/1`
- Fixed the implementation of `ExArray.from_erlang_array/1` to return an `ExArray`

## v0.1.1 (2023-04-21)

- Changed the internal implementation of `ExArray`
- Improved the typespecs and documentations

## v0.1.0 (2023-04-20)

- Version initial
