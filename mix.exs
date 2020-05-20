defmodule Kandires.MixProject do
  use Mix.Project

  def project do
    [
      app: :kandires,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(Mix.env())
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Kandires.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:phoenix, path: "deps/phoenix", override: true},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:cors_plug, "~> 1.5"},
      {:phoenix_live_view, path: "deps/phoenix_live_view", override: true},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:number, "~> 1.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.14.0"},
      # {:recase, "~> 0.4"},
      {:recase, github: "sobolevn/recase", branch: "master"},
      {:scrivener_ecto, "~> 2.0"},
      {:accessible, "~> 0.2.1"},
      {:decoratex, github: "tmepple/decoratex", branch: "master"},
      {:maybe, "~> 1.0.0"},
      {:quick_alias, github: "werkzeugh/quick_alias", branch: "master"},
      # {:quick_alias, "~> 0.1.0"},
      {:xlsxir, "~> 1.6.4"},
      {:csv, ">= 2.3.0"},
      {:memoize, "~> 1.2"},
      {:mojito, "~> 0.6.1"},
      {:basic_auth, "~> 2.2.2"},
      {:blankable, "~> 1.0.0"},
      {:download, "~> 0.0.0"},
      {:pow, "1.0.18"},
      {:bamboo, "~> 1.4"},
      {:ancestry, "~> 0.1.3"},
      {:atomic_map, "~> 0.8"},
      {:surface, github: "msaraiva/surface", branch: "master"},
      {:countries, "~> 1.5"},
      {:exsync, "~> 0.2", only: :dev},
      {:exi18n, "~> 0.8.0"},
      {:yaml_elixir, "~> 1.3.0"},
      {:tzdata, "~> 1.0.1"},
      {:loggix, "~> 0.0.7"},
      {:timex, "~> 3.5"}
    ]
  end

  defp deps(:prod) do
    deps() ++ [{:kandis, github: "werkzeugh/kandis", tag: "0.3.14", only: [:prod]}]
  end

  defp deps(_) do
    deps() ++ [{:kandis, path: "/www/kandis"}]
  end
end
