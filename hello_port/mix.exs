defmodule HelloPort.MixProject do
  use Mix.Project

  def project do
    [
      app: :hello_port,
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
      extra_applications: [:logger,  :reaxt]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:reaxt, "~> 2.0", github: "kbrw/reaxt"},
    ]
  end
end
