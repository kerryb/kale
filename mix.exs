defmodule Kale.MixProject do
  use Mix.Project

  def project do
    [
      app: :kale,
      version: "0.5.1",
      description: description(),
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      dialyzer: dialyzer()
    ]
  end

  defp description do
    "Basic given-when-then steps for ExUnit tests"
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Kerry Buckley"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/kerryb/kale"},
      source_url: "https://github.com/kerryb/kale"
    ]
  end

  defp dialyzer do
    [
      plt_add_deps: :transitive
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
