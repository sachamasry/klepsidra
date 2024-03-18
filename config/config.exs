# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :klepsidra,
  ecto_repos: [Klepsidra.Repo]

# Configures the endpoint
config :klepsidra, KlepsidraWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: KlepsidraWeb.ErrorHTML, json: KlepsidraWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Klepsidra.PubSub,
  live_view: [signing_salt: "3h4E5TnT"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :klepsidra, Klepsidra.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
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

# CLDR Units configuration: define custom units
config :ex_cldr_units,  :additional_units,
  six_minute_block: [base_unit: :minute, factor: 6, offset: 0],
  quarter_hour: [base_unit: :minute, factor: 15, offset: 0],
  half_hour: [base_unit: :minute, factor: 30, offset: 0]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Import LiveView Native configuration
import_config "native.exs"
