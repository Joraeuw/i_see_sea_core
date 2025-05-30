defmodule ISeeSea.MixProject do
  use Mix.Project

  def project do
    [
      app: :i_see_sea,
      version: "2.0.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ISeeSea.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.4", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.2"},
      {:bcrypt_elixir, "~> 3.1.0"},
      {:guardian, "~> 2.3.2"},
      {:guardian_db, "~> 3.0.0"},
      {:open_api_spex, "~> 3.18"},
      {:redoc_ui_plug, "~> 0.2.1"},
      {:prom_ex, "~> 1.9.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:logger_json, "~> 5.1.4"},
      {:excoveralls, "~> 0.18.1", only: :test},
      {:goal, "~> 1.0.2"},
      {:faker, "~> 0.18", only: [:dev, :test]},
      {:flop, "~> 0.25.0"},
      {:image, "~> 0.46.0"},
      {:cors_plug, "~> 3.0"},
      {:uuid, "~> 1.1.8"},
      {:oban, "~> 2.17.10"},
      {:timex, "~> 3.7.11"},
      {:gen_smtp, "~> 1.0"},
      {:httpoison, "~> 1.8"},
      {:ex_utils, "~> 0.1.7"},
      {:linguist, "~> 0.4"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build", "spec"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["esbuild i_see_sea", "tailwind i_see_sea"],
      "assets.deploy": [
        "tailwind default --minify",
        "phx.digest"
      ],
      spec: ["openapi.spec.json --spec ISeeSeaWeb.ApiSpec"]
    ]
  end
end
