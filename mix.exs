defmodule LearningElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :learning_elixir,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:reaxt_webpack] ++ Mix.compilers
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy, :inets],
      mod: {LearningElixir, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:reaxt, tag: "2.0.1", github: "kbrw/reaxt"},
      {:plug_cowboy, "~> 1.0.0"},
      {:poison, "~> 2.1.0"},
    ]
  end
end
