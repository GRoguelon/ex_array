defimpl Inspect, for: ExArray do
  @moduledoc false

  import Inspect.Algebra

  @spec inspect(@for.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(%@for{} = struct, opts) do
    concat([
      "#ExArray<",
      to_doc(@for.to_list(struct), opts),
      ", fixed=",
      Atom.to_string(@for.is_fix(struct)),
      ", default=",
      inspect(@for.default(struct)),
      ">"
    ])
  end
end
