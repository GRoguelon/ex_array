defimpl Enumerable, for: ExArray do
  @moduledoc false

  @spec count(ExArray.t()) :: {:ok, non_neg_integer()}
  def count(arr) do
    {:ok, ExArray.size(arr)}
  end

  @spec member?(ExArray.t(), ExArray.element()) :: {:error, __MODULE__}
  def member?(_arr, _value) do
    {:error, __MODULE__}
  end

  @spec reduce(ExArray.t(), Enumerable.acc(), Enumerable.reducer()) :: Enumerable.result()
  def reduce(%ExArray{content: c}, acc, fun) do
    Enumerable.reduce(:array.to_list(c), acc, fun)
  end

  @spec slice(ExArray.t()) :: {:ok, non_neg_integer(), Enumerable.slicing_fun()}
  def slice(%ExArray{content: c}) do
    size = :array.size(c)
    {:ok, size, &Enumerable.List.slice(:array.to_list(c), &1, &2, size)}
  end
end
