# Changelog

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
