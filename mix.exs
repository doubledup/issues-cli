defmodule Issues.MixProject do
  use Mix.Project

  def project do
    [
      app: :issues,
      deps: deps(),
      elixir: "~> 1.7.4",
      escript: escript_config(),
      name: "Issues CLI",
      source_url: "https://github.com/doubledup/issues-cli",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0",
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.2.0"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.19.1"},
      {:earmark, "~> 1.3.0"}
    ]
  end

  defp escript_config do
    [
      main_module: Issues.CLI
    ]
  end
end
