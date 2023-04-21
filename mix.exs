defmodule ExArray.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_array,
      version: "0.1.0",
      elixir: "~> 1.14",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      description: "A wrapper module for Erlang's array.",
      source_url: "https://github.com/groguelon/ex_array"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      # These are the default files included in the package
      files: ~w[lib .formatter.exs mix.exs README* LICENSE*],
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/groguelon/ex_array"
      }
    ]
  end

  defp docs do
    [
      formatters: ["html"],
      main: "readme",
      extras: ["README.md", "LICENSE"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
