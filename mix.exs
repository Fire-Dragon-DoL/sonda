defmodule Sonda.MixProject do
  use Mix.Project

  def project do
    [
      app: :sonda,
      version: "0.1.0",
      elixir: ">= 1.6.0",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    []
  end
end
