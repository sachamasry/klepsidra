import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :klepsidra, Klepsidra.Repo,
  database: Path.expand("../klepsidra_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

config :klepsidra, Klepsidra.ReporterRepo,
  database: Path.expand("../db/reporter_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :klepsidra, KlepsidraWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "rAphGD+z8WlJq/eQccHqCldYLmiOvi+4+8xVTZw0CFNdjDqVjw1Fys86GQgfEzvC",
  server: false

config :klepsidra, Oban, testing: :inline

# In test we don't send emails.
config :klepsidra, Klepsidra.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
