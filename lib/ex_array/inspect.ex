defimpl Inspect, for: ExArray do
  @moduledoc false

  import Inspect.Algebra

  @spec inspect(ExArray.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(arr, opts) do
    concat([
      "#ExArray<",
      to_doc(ExArray.to_list(arr), opts),
      ", fixed=",
      Atom.to_string(ExArray.is_fix(arr)),
      ", default=",
      inspect(ExArray.default(arr)),
      ">"
    ])
  end
end
