defimpl Enumerable, for: ExArray do
  @moduledoc false

  @spec count(@for.t()) :: {:ok, non_neg_integer()}
  def count(arr) do
    {:ok, @for.size(arr)}
  end

  @spec member?(@for.t(), @for.value()) :: {:error, __MODULE__}
  def member?(_arr, _value) do
    {:error, __MODULE__}
  end

  @spec reduce(@for.t(), Enumerable.acc(), Enumerable.reducer()) :: Enumerable.result()
  def reduce(arr, acc, fun) do
    Enumerable.reduce(@for.to_list(arr), acc, fun)
  end

  if Version.match?(System.version(), ">= 1.18.0") do
    # Elixir 1.18+ deprecated the 2-arity slicing_fun. Use the 3-arity form
    # (introduced in 1.16) which accepts a step parameter.
    @spec slice(@for.t()) ::
            {:ok, size :: non_neg_integer(),
             (non_neg_integer(), pos_integer(), pos_integer() -> list())}
    def slice(arr) do
      size = @for.size(arr)

      {:ok, size,
       fn start, length, step ->
         Enum.map(start..(start + (length - 1) * step)//step, &@for.get(arr, &1))
       end}
    end
  else
    # Elixir 1.14 / 1.15 don't support the 3-arity form. Use the 2-arity
    # slicing_fun, which is not deprecated on these versions.
    @spec slice(@for.t()) ::
            {:ok, size :: non_neg_integer(), (non_neg_integer(), pos_integer() -> list())}
    def slice(arr) do
      size = @for.size(arr)

      {:ok, size,
       fn start, length ->
         Enum.map(start..(start + length - 1), &@for.get(arr, &1))
       end}
    end
  end
end
