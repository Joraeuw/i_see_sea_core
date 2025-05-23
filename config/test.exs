import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
if is_nil(System.get_env("DATABASE_URL")) do
  config :i_see_sea, ISeeSea.Repo,
    log: false,
    username: "postgres",
    password: "postgres",
    hostname: "localhost",
    database: "i_see_sea_test#{System.get_env("MIX_TEST_PARTITION")}",
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: System.schedulers_online() * 2
else
  config :i_see_sea, ISeeSea.Repo,
    log: false,
    url: System.get_env("DATABASE_URL"),
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: System.schedulers_online() * 2
end

config :i_see_sea, Oban, queues: false, plugins: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :i_see_sea, ISeeSeaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "l/jNaYbNCLwc0K/QdY7d5TklGsdAD3pSMEIceTnP5vBHrSFmz/ru7ge0XMLba51O",
  server: false

# In test we don't send emails.
config :i_see_sea, ISeeSea.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
