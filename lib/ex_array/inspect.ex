defimpl Inspect, for: ExArray do
  @moduledoc false

  import Inspect.Algebra

  @spec inspect(@for.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(%@for{} = struct, opts) do
    concat([
      "#ExArray<",
      to_doc(elements(struct, opts.limit), opts),
      ", fixed=",
      Atom.to_string(@for.fixed?(struct)),
      ", default=",
      to_doc(@for.default(struct), opts),
      ">"
    ])
  end

  # Only materialize what will be printed: one extra element lets `to_doc/2` emit "...".
  defp elements(struct, :infinity), do: @for.to_list(struct)
  defp elements(struct, limit), do: Enum.slice(struct, 0, limit + 1)
end
