defmodule ExArray.MixProject do
  use Mix.Project

  @name :ex_array
  @source_url "https://github.com/GRoguelon/ex_array"
  @version "2.0.0"

  def project do
    [
      app: @name,
      version: @version,
      elixir: "~> 1.14",
      consolidate_protocols: Mix.env() != :test,
      package: package(),
      dialyzer: dialyzer(),
      deps: deps(),
      docs: docs(),
      description: "A wrapper module for Erlang's array.",
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  defp package do
    [
      name: @name,
      files: ~w[lib .formatter.exs mix.exs README.md CHANGELOG.md UPGRADING.md LICENSE],
      maintainers: ["Geoffrey Roguelon"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "https://ex-array.hexdocs.pm/#{@version}/changelog.html"
      }
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      formatters: ["html"],
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "UPGRADING.md", "LICENSE"],
      # Past releases reference functions that have since been removed.
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.3", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
