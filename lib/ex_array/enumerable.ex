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

  # Arrays are often traversed only partially (`Enum.take/2`, `Enum.find/2`, ...), so the
  # first `@prefix` elements are walked by index without materializing the array. If the
  # reduction is still running after that, the rest is reduced as a list, which is the
  # fastest way to traverse a whole `:array`.
  @prefix 32

  @spec reduce(@for.t(), Enumerable.acc(), Enumerable.reducer()) :: Enumerable.result()
  def reduce(%@for{arr: arr}, acc, fun) do
    if :array.size(arr) <= @prefix * 4 do
      Enumerable.List.reduce(:array.to_list(arr), acc, fun)
    else
      reduce_prefix(arr, 0, acc, fun)
    end
  end

  defp reduce_prefix(_arr, _index, {:halt, acc}, _fun) do
    {:halted, acc}
  end

  defp reduce_prefix(arr, index, {:suspend, acc}, fun) do
    {:suspended, acc, &reduce_prefix(arr, index, &1, fun)}
  end

  defp reduce_prefix(arr, @prefix, acc, fun) do
    Enumerable.List.reduce(:lists.nthtail(@prefix, :array.to_list(arr)), acc, fun)
  end

  defp reduce_prefix(arr, index, {:cont, acc}, fun) do
    reduce_prefix(arr, index + 1, fun.(:array.get(index, arr), acc), fun)
  end

  @spec slice(@for.t()) ::
          {:ok, size :: non_neg_integer(),
           (non_neg_integer(), pos_integer(), pos_integer() -> list())}
  def slice(%@for{arr: arr}) do
    {:ok, :array.size(arr),
     fn start, length, step ->
       Enum.map(start..(start + (length - 1) * step)//step, &:array.get(&1, arr))
     end}
  end
end
