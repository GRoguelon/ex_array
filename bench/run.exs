# Benchmarks ExArray's protocol implementations and Access with Benchee, measuring run
# time, memory usage and reductions. Every case runs as its own Benchee suite so that
# results saved from one checkout can be compared against another, case by case.
#
#   elixir bench/run.exs --path . --tag new
#   elixir bench/run.exs --path ../old --tag old --save-dir tmp/bench
#   elixir bench/run.exs --path . --tag new --load-dir tmp/bench
#
# Use bench/compare.sh to compare a git revision against the working tree.

{opts, _args} =
  OptionParser.parse!(System.argv(),
    strict: [path: :string, tag: :string, save_dir: :string, load_dir: :string, sizes: :string]
  )

Mix.install([
  {:ex_array, path: Path.expand(Keyword.get(opts, :path, "."))},
  {:benchee, "~> 1.3"}
])

tag = Keyword.get(opts, :tag, "current")

sizes =
  opts
  |> Keyword.get(:sizes, "100,10000,1000000")
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

inputs =
  Map.new(sizes, fn n ->
    {"n=#{n}", %{arr: ExArray.from_list(Enum.to_list(1..n)), n: n, mid: div(n, 2)}}
  end)

cases = [
  {"Enum.reduce/3 (sum)", fn %{arr: arr} -> Enum.reduce(arr, 0, &+/2) end},
  {"Enum.to_list/1", fn %{arr: arr} -> Enum.to_list(arr) end},
  {"Enum.map/2", fn %{arr: arr} -> Enum.map(arr, &(&1 + 1)) end},
  {"Enum.take/2 (first 10)", fn %{arr: arr} -> Enum.take(arr, 10) end},
  {"Enum.find/2 (first element)", fn %{arr: arr} -> Enum.find(arr, &(&1 == 1)) end},
  {"Enum.find/2 (middle element)", fn %{arr: arr, mid: mid} -> Enum.find(arr, &(&1 == mid)) end},
  {"Enum.member?/2 (last element)", fn %{arr: arr, n: n} -> Enum.member?(arr, n) end},
  {"Enum.at/2 (middle)", fn %{arr: arr, mid: mid} -> Enum.at(arr, mid) end},
  {"Enum.slice/3 (10 from middle)", fn %{arr: arr, mid: mid} -> Enum.slice(arr, mid, 10) end},
  {"Enum.zip/2 (with itself)", fn %{arr: arr} -> Enum.zip(arr, arr) end},
  {"Enum.into/2 (append to itself)", fn %{arr: arr} -> Enum.into(arr, arr) end},
  {"inspect/1 (default limit)", fn %{arr: arr} -> inspect(arr) end},
  {"Access arr[i]", fn %{arr: arr, mid: mid} -> arr[mid] end},
  {"Access put_in/2", fn %{arr: arr, mid: mid} -> put_in(arr[mid], 0) end},
  {"Access update_in/2", fn %{arr: arr, mid: mid} -> update_in(arr[mid], &(&1 + 1)) end}
]

for {{name, fun}, index} <- Enum.with_index(cases, 1) do
  file = "#{index}.benchee"

  persistence =
    Enum.reject(
      [
        save: opts[:save_dir] && [path: Path.join(opts[:save_dir], file), tag: tag],
        load: opts[:load_dir] && Path.join(opts[:load_dir], file)
      ],
      fn {_key, value} -> is_nil(value) end
    )

  Benchee.run(
    %{name => fun},
    [
      inputs: inputs,
      warmup: 0.5,
      time: 1,
      memory_time: 0.5,
      reduction_time: 0.5,
      title: name,
      print: [configuration: false, benchmarking: false]
    ] ++ persistence
  )
end
