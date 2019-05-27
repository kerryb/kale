defmodule Kale.MixProject do
  use Mix.Project

  def project do
    [
      app: :kale,
      version: "0.1.0",
      description: description(),
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
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
end
