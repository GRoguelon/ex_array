defmodule ExArray do
  @moduledoc """
  A wrapper module for Erlang's array.
  """

  @modulestr __MODULE__ |> Module.split() |> Enum.join(".")

  @default nil

  defstruct arr: :array.new(default: @default)

  ## Types

  @typedoc "Defines the module typespec"
  @type t :: %__MODULE__{arr: array()}

  @typedoc "Defines the number of values in the array."
  @type size :: non_neg_integer()

  @typedoc "Defines the number maximum of values in the array."
  @type max :: non_neg_integer()

  @typedoc "Defines the array index."
  @type index() :: non_neg_integer()

  @typedoc "Defines the array value."
  @type value() :: term()

  @typedoc "Defines the array default value."
  @type default() :: term()

  @typedoc "Defines the possible options."
  @type option() ::
          {:fixed, boolean()}
          | :fixed
          | {:default, term()}
          | {:size, non_neg_integer()}
          | (size :: non_neg_integer())

  @typedoc "Defines the options accepted by `new/1`."
  @type options() :: option() | [option()]

  @typedoc """
  Represents an `:array` from Erlang. The representation is not documented and is subject to change without notice.
  """
  @opaque array() :: {:array, size(), max(), default :: term(), elements :: elements(term())}

  @typedoc "Represents a keyword list where the index is the key and the value is the element."
  @opaque orddict() :: [{index :: index(), value :: term()}]

  @typep elements(t) :: non_neg_integer() | element_tuple(t) | nil

  @typep element_tuple(t) ::
           {t, t, t, t, t, t, t, t, t, t}
           | {element_tuple(t), element_tuple(t), element_tuple(t), element_tuple(t), element_tuple(t),
              element_tuple(t), element_tuple(t), element_tuple(t), element_tuple(t), element_tuple(t),
              non_neg_integer()}

  ## Behaviours

  @behaviour Access

  @impl Access
  @spec fetch(t(), index()) :: :error | {:ok, any}
  def fetch(%__MODULE__{} = ex_arr, index) do
    if value = get(ex_arr, index) do
      {:ok, value}
    else
      :error
    end
  end

  @impl Access
  @spec get_and_update(t(), index(), (any() -> {any(), any()})) :: {any(), t()}
  def get_and_update(%__MODULE__{} = ex_arr, index, fun) when is_function(fun, 1) do
    {get, update} = ex_arr |> get(index) |> fun.()

    {get, set(ex_arr, index, update)}
  end

  @impl Access
  @spec pop(t(), index()) :: {any(), t()}
  def pop(%__MODULE__{} = ex_arr, index) do
    if value = get(ex_arr, index) do
      {value, reset(ex_arr, index)}
    else
      {nil, ex_arr}
    end
  end

  ## Public functions

  @doc """
  Creates a new, extendible array with initial size zero. The default value is `nil`.

  ## Examples

      iex> #{@modulestr}.new()
      #ExArray<[], fixed=false, default=nil>
  """
  @spec new() :: t()
  def new() do
    new(default: @default)
  end

  @doc """
  Creates a new fixed array according to the given options.
  By default, the array is extendible and has initial size zero.
  The default value is `nil`, if not specified.

  `options` is a single term or a list of terms, selected from the following:

  * `n` or `{:size, n}`
      * Specifies the initial size of the array; this also implies `{:fixed, true}`.
      * If `n` is not a non-negative integer, the call raises `ArgumentError`.
  * `{:fixed, true}`
      * Creates a fixed-size array.
  * `{:default, value}`
      * Sets the default value for the array to `value`.

  ## Examples

      iex> #{@modulestr}.new(5)
      #ExArray<[nil, nil, nil, nil, nil], fixed=true, default=nil>

      iex> #{@modulestr}.new(size: 5)
      #ExArray<[nil, nil, nil, nil, nil], fixed=true, default=nil>

      iex> #{@modulestr}.new(fixed: true)
      #ExArray<[], fixed=true, default=nil>

      iex> #{@modulestr}.new(default: 0)
      #ExArray<[], fixed=false, default=0>

      iex> #{@modulestr}.new(size: 5, fixed: true, default: 0)
      #ExArray<[0, 0, 0, 0, 0], fixed=true, default=0>
  """
  @spec new(options()) :: t()
  def new(size) when is_integer(size) do
    new(size: size, default: @default)
  end

  def new(options) when is_list(options) do
    options = Keyword.put_new(options, :default, @default)

    %__MODULE__{arr: :array.new(options)}
  end

  @doc """
  Returns `true` if `arr` appears to be an array, otherwise `false`.
  Note that the check is only shallow; there is no guarantee that `arr` is a well-formed array
  representation even if this function returns `true`.
  """
  @spec is_array(any()) :: boolean()
  def is_array(%__MODULE__{arr: arr}) do
    :array.is_array(arr)
  end

  def is_array(_any) do
    false
  end

  @doc """
  Checks if the array has fixed size. Returns `true` if the array is fixed, otherwise `false`.
  """
  @spec is_fix(t()) :: boolean()
  def is_fix(%__MODULE__{arr: arr}) do
    :array.is_fix(arr)
  end

  @doc """
  Gets the number of entries in the array.
  Entries are numbered from 0 to `size(array)-1`; hence, this is also the index of
  the first entry that is guaranteed to not have been previously set.
  """
  @spec size(t()) :: non_neg_integer()
  def size(%__MODULE__{arr: arr}) do
    :array.size(arr)
  end

  @doc """
  Gets the number of entries in the array up until the last non-default valued entry.
  In other words, returns `index+1` if `index` is the last non-default valued entry in the array,
  or zero if no such entry exists.
  """
  @spec sparse_size(t()) :: non_neg_integer()
  def sparse_size(%__MODULE__{arr: arr}) do
    :array.sparse_size(arr)
  end

  @doc """
  Gets the value used for uninitialized entries.
  """
  @spec default(t()) :: default()
  def default(%__MODULE__{arr: arr}) do
    :array.default(arr)
  end

  @doc """
  Gets the value of entry `index`. If `index` is not a nonnegative integer, or if the array has
  fixed size and `index` is larger than the maximum index, the call raises `ArgumentError`.
  """
  @spec get(t(), index()) :: value()
  def get(%__MODULE__{arr: arr}, index) do
    :array.get(index, arr)
  end

  @doc """
  Sets entry `index` of the array to `val`.
  If `index` is not a nonnegative integer, or if the array has fixed size and `index` is
  larger than the maximum index, the call raises `ArgumentError`.
  """
  @spec set(t(), index(), value()) :: t()
  def set(%__MODULE__{arr: arr}, index, value) do
    %__MODULE__{arr: :array.set(index, value, arr)}
  end

  @doc """
  Check if two arrays are equal using ===.
  """
  @spec equal?(t(), t()) :: boolean()
  def equal?(%__MODULE__{} = struct1, %__MODULE__{} = struct2) do
    to_list(struct1) === to_list(struct2)
  end

  @doc """
  Fixes the size of the array. This prevents it from growing automatically upon insertion.
  """
  @spec fix(t()) :: t()
  def fix(%__MODULE__{arr: arr}) do
    %__MODULE__{arr: :array.fix(arr)}
  end

  @doc """
  Makes the array resizable.
  """
  @spec relax(t()) :: t()
  def relax(%__MODULE__{arr: arr}) do
    %__MODULE__{arr: :array.relax(arr)}
  end

  @doc """
  Resets entry `index` to the default value for the array.
  If the value of entry `index` is the default value the array will be returned unchanged.
  Reset will never change size of the array. Shrinking can be done explicitly by calling `resize/2`.

  If `index` is not a nonnegative integer, or if the array has fixed size and `index` is
  larger than the maximum index, the call raises `ArgumentError`.
  """
  @spec reset(t(), index()) :: t()
  def reset(%__MODULE__{arr: arr}, index) do
    %__MODULE__{arr: :array.reset(index, arr)}
  end

  @doc """
  Changes the size of the array to that reported by `sparse_size/1`.
  If the given array has fixed size, the resulting array will also have fixed size.
  """
  @spec resize(t()) :: t()
  def resize(%__MODULE__{arr: arr}) do
    %__MODULE__{arr: :array.resize(arr)}
  end

  @doc """
  Changes the size of the array.
  If `size` is not a nonnegative integer, the call raises `ArgumentError`.
  If the given array has fixed size, the resulting array will also have fixed size.
  """
  @spec resize(t(), non_neg_integer()) :: t()
  def resize(%__MODULE__{arr: arr}, size) do
    %__MODULE__{arr: :array.resize(size, arr)}
  end

  @doc """
  Converts an Erlang's array to an array.
  All properties (size, elements, default value, fixedness) of the original array are preserved.

  If `erl_array` is not an Erlang's array, the call raises `ArgumentError`.
  """
  @spec from_erlang_array(array()) :: t()
  def from_erlang_array(erl_array) do
    unless :array.is_array(erl_array) do
      raise ArgumentError
    end

    %__MODULE__{arr: erl_array}
  end

  @doc """
  Converts a list to an extendible array.
  `default` is used as the value for uninitialized entries of the array.

  If `list` is not a proper list, the call raises `ArgumentError`.
  """
  @spec from_list(list(), any()) :: t()
  def from_list(list, default \\ nil) do
    %__MODULE__{arr: :array.from_list(list, default)}
  end

  @doc """
  Converts an ordered list of pairs `{index, value}` to a corresponding extendible array.
  `default` is used as the value for uninitialized entries of the array.

  If `orddict` is not a proper, ordered list of pairs whose first elements are nonnegative integers,
  the call raises `ArgumentError`.
  """
  @spec from_orddict(orddict(), any()) :: t()
  def from_orddict(orddict, default \\ nil) do
    %__MODULE__{arr: :array.from_orddict(orddict, default)}
  end

  @doc """
  Converts the array to its underlying Erlang's array.
  """
  @spec to_erlang_array(t()) :: array()
  def to_erlang_array(%__MODULE__{arr: arr}) do
    arr
  end

  @doc """
  Converts the array to a list.
  """
  @spec to_list(t()) :: list()
  def to_list(%__MODULE__{arr: arr}) do
    :array.to_list(arr)
  end

  @doc """
  Converts the array to a list, skipping default-valued entries.
  """
  @spec sparse_to_list(t()) :: list()
  def sparse_to_list(%__MODULE__{arr: arr}) do
    :array.sparse_to_list(arr)
  end

  @doc """
  Converts the array to an ordered list of pairs `{index, value}`.
  """
  @spec to_orddict(t()) :: orddict()
  def to_orddict(%__MODULE__{arr: arr}) do
    :array.to_orddict(arr)
  end

  @doc """
  Converts the array to an ordered list of pairs `{index, value}`, skipping default-valued entries.
  """
  @spec sparse_to_orddict(t()) :: orddict()
  def sparse_to_orddict(%__MODULE__{arr: arr}) do
    :array.sparse_to_orddict(arr)
  end

  @doc """
  Maps the given function onto each element of the array.
  The elements are visited in order from the lowest index to the highest.

  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec map(t(), (index(), value() -> any())) :: t()
  def map(%__MODULE__{arr: arr}, fun) when is_function(fun, 2) do
    %__MODULE__{arr: :array.map(fun, arr)}
  end

  @doc """
  Maps the given function onto each element of the array, skipping default-valued entries.
  The elements are visited in order from the lowest index to the highest.

  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec sparse_map(t(), (index(), value() -> any())) :: t()
  def sparse_map(%__MODULE__{arr: arr}, fun) when is_function(fun, 2) do
    %__MODULE__{arr: :array.sparse_map(fun, arr)}
  end

  @doc """
  Folds the elements of the array using the given function and initial accumulator value.
  The elements are visited in order from the lowest index to the highest.

  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec foldl(t(), acc, (index(), value(), acc -> acc)) :: acc when acc: var
  def foldl(%__MODULE__{arr: arr}, acc, fun) when is_function(fun, 3) do
    :array.foldl(fun, acc, arr)
  end

  @doc """
  Folds the elements of the array using the given function and initial accumulator value,
  skipping default-valued entries.
  The elements are visited in order from the lowest index to the highest.

  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec sparse_foldl(t(), acc, (index(), value(), acc -> acc)) :: acc when acc: var
  def sparse_foldl(%__MODULE__{arr: arr}, acc, fun) when is_function(fun, 3) do
    :array.sparse_foldl(fun, acc, arr)
  end

  @doc """
  Folds the elements of the array right-to-left using the given function and initial accumulator value.
  The elements are visited in order from the highest index to the lowest.

  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec foldr(t(), acc, (index(), value(), acc -> acc)) :: acc when acc: var
  def foldr(%__MODULE__{arr: arr}, acc, fun) when is_function(fun, 3) do
    :array.foldr(fun, acc, arr)
  end

  @doc """
  Folds the elements of the array right-to-left using the given function and initial accumulator value,
  skipping default-valued entries.
  The elements are visited in order from the highest index to the lowest.

  If `fun` is not a function, the call raises `ArgumentError`.
  """
  @spec sparse_foldr(t(), acc, (index(), value(), acc -> acc)) :: acc when acc: var
  def sparse_foldr(%__MODULE__{arr: arr}, acc, fun) when is_function(fun, 3) do
    :array.sparse_foldr(fun, acc, arr)
  end
end
