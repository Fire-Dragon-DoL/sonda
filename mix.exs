defmodule Sonda.MixProject do
  use Mix.Project

  def project do
    [
      app: :sonda,
      version: "0.1.0",
      elixir: ">= 1.6.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: consolidate_protocols(Mix.env()),
      # Docs
      name: "Sonda",
      source_url: "https://github.com/Fire-Dragon-DoL/sonda",
      homepage_url: "https://github.com/Fire-Dragon-DoL/sonda",
      docs: docs(),
      dialyzer: dialyzer()
    ]
  end

  def docs do
    [
      main: "README.md",
      extras: [
        "README.md": [filename: "README.md", title: "Usage"]
      ],
      extra_section: "GUIDES",
      formatters: ["html"],
      authors: ["Francesco Belladonna"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  def deps do
    [
      {:dialyxir, ">= 1.0.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.21.3", only: [:dev], runtime: false}
    ]
  end

  def consolidate_protocols(:test), do: false
  def consolidate_protocols(_), do: true

  def dialyzer do
    [ignore_warnings: "dialyzer.ignore-warnings"]
  end
end
