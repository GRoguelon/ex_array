defimpl Collectable, for: ExArray do
  @moduledoc false

  # Like lists and bitstrings, collecting into an array appends the elements after the
  # existing entries, starting at index `size/1`. Fixed-size arrays cannot grow, so
  # collecting any element into them raises.
  @spec into(@for.t()) ::
          {initial_acc :: term(),
           collector :: (term(), @protocol.command() -> @protocol.t() | term())}
  def into(original) do
    cond do
      @for.fixed?(original) -> into_fixed(original)
      @for.size(original) == 0 -> into_empty(original)
      true -> into_extendible(original)
    end
  end

  defp into_fixed(original) do
    collector = fn
      _acc, {:cont, _value} ->
        raise ArgumentError,
              "cannot collect into a fixed-size ExArray, call ExArray.relax/1 first"

      acc, :done ->
        acc

      _acc, :halt ->
        :ok
    end

    {original, collector}
  end

  # Building the array at once with `:array.from_list/2` is much faster than setting the
  # entries one by one.
  defp into_empty(original) do
    collector = fn
      list, {:cont, value} -> [value | list]
      list, :done -> @for.from_list(:lists.reverse(list), @for.default(original))
      _list, :halt -> :ok
    end

    {[], collector}
  end

  defp into_extendible(original) do
    collector = fn
      {index, arr}, {:cont, value} -> {index + 1, @for.set(arr, index, value)}
      {_index, arr}, :done -> arr
      _acc, :halt -> :ok
    end

    {{@for.size(original), original}, collector}
  end
end
