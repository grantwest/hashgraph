defmodule Hashgraph.MixProject do
  use Mix.Project

  def project do
    [
      app: :hashgraph,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mldht]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mldht, "~> 0.0.3"},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
    ]
  end
end
