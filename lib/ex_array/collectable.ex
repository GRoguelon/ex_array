defimpl Collectable, for: ExArray do
  @moduledoc false
  @spec into(ExArray.t()) ::
          {[], (list(), {:cont, term()} -> list()) | (list(), :done -> ExArray.t()) | (list(), :halt -> :ok)}
  def into(original) do
    {[],
     fn
       list, {:cont, x} -> [x | list]
       list, :done -> ExArray.from_list(ExArray.to_list(original) ++ :lists.reverse(list))
       _, :halt -> :ok
     end}
  end
end
