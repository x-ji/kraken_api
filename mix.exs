defmodule KrakenApi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kraken_api,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "kraken_api",
      source_url: "https://github.com/x-ji/kraken_api"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:httpoison],
      env: [api_endpoint: "https://api.kraken.com",
            api_version: "0"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 0.13"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    "Elixir library for Kraken (kraken.com) exchange API."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["JI Xiang"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/x-ji/kraken_api"}
    ]
  end
end
