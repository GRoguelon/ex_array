defimpl Collectable, for: ExArray do
  @moduledoc false

  @spec into(@for.t()) ::
          {initial_acc :: term(),
           collector :: (term(), @protocol.command() -> @protocol.t() | term())}
  def into(original) do
    initial = {@for.size(original), original}

    collector = fn
      {index, arr}, {:cont, value} ->
        {index + 1, @for.set(arr, index, value)}

      {_index, arr}, :done ->
        arr

      _acc, :halt ->
        :ok
    end

    {initial, collector}
  end
end
