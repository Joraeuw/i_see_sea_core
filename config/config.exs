# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :i_see_sea,
  ecto_repos: [ISeeSea.Repo],
  generators: [timestamp_type: :utc_datetime]

config :i_see_sea, backend_url: "localhost:4000"

# Configures the endpoint
config :i_see_sea, ISeeSeaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ISeeSeaWeb.ErrorHTML, json: ISeeSeaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ISeeSea.PubSub,
  live_view: [signing_salt: "FEWjgVlX"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :i_see_sea, email: "iliad.support@tu-varna.bg"

config :i_see_sea, Oban,
  repo: ISeeSea.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [user_email_verification: 10]

config :i_see_sea, ISeeSea.Authentication.Tokenizer,
  issuer: "i_see_sea",
  secret_key: "OH+s9QEzQ4V5lJk7t1XHbfwxqg41oKCV/nAREVpyzmLWh6R+ujXQE+EO9QzgVM2k"

config :guardian, Guardian.DB,
  repo: ISeeSea.Repo,
  schema_name: "guardian_tokens",
  sweep_interval: 10

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  i_see_sea: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  i_see_sea: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Goal regex config
config :goal,
  phone_regex: ~r/^(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/

# Logger config for Grafana and Loki

# config :logger, backends: [LoggerJSON]
# config :i_see_sea, ISeeSea.Repo, loggers: [{LoggerJSON.Ecto, :log, [:info]}]

# config :logger_json, :backend,
#  metadata: [:file, :line, :function, :module, :application, :httpRequest, :query],
#  formatter: LoggerJSON.Formatters.BasicLogger

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
