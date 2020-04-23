defmodule Sonda.MixProject do
  use Mix.Project

  @external_resource path = Path.join(__DIR__, "VERSION")
  @version path |> File.read!() |> String.trim()

  def project do
    [
      app: :sonda,
      version: @version,
      elixir: ">= 1.6.0",
      package: package(),
      test_paths: ["test/automated"],
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

  def package do
    [
      maintainers: ["Francesco Belladonna"],
      description:
        "Sonda is a telemetry library for Elixir, providing configurable sinks for
      recording signals",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Fire-Dragon-DoL/sonda"},
      files: [
        ".formatter.exs",
        "mix.exs",
        "README.md",
        "VERSION",
        "test",
        "lib",
        "LICENSE"
      ]
    ]
  end

  def docs do
    [
      main: "README.md",
      extras: [
        "README.md": [filename: "README.md", title: "Getting Started"]
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
