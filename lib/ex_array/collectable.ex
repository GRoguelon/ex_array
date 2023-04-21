defimpl Collectable, for: ExArray do
  @moduledoc false

  @spec into(@for.t()) :: {initial_acc :: term(), collector :: (term(), @protocol.command() -> @protocol.t() | term())}
  def into(original) do
    collector = fn
      list, {:cont, value} ->
        [value | list]

      list, :done ->
        @for.from_list(@for.to_list(original) ++ :lists.reverse(list))

      _list, :halt ->
        :ok
    end

    {[], collector}
  end
end
