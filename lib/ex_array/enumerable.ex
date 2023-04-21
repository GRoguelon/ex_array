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

  @spec slice(@for.t()) :: {:ok, size :: non_neg_integer(), Enumerable.to_list_fun()}
  def slice(arr) do
    size = @for.size(arr)

    {:ok, size, &@for.to_list/1}
  end
end
