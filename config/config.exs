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
  five_minute_increment: [base_unit: :minute, factor: 5, offset: 0],
  six_minute_increment: [base_unit: :minute, factor: 6, offset: 0],
  ten_minute_increment: [base_unit: :minute, factor: 10, offset: 0],
  twelve_minute_increment: [base_unit: :minute, factor: 12, offset: 0],
  fifteen_minute_increment: [base_unit: :minute, factor: 15, offset: 0],
  eighteen_minute_increment: [base_unit: :minute, factor: 18, offset: 0],
  twenty_minute_increment: [base_unit: :minute, factor: 20, offset: 0],
  twenty_four_minute_increment: [base_unit: :minute, factor: 24, offset: 0],
  thirty_minute_increment: [base_unit: :minute, factor: 30, offset: 0],
  thirty_six_minute_increment: [base_unit: :minute, factor: 36, offset: 0],
  fourty_five_minute_increment: [base_unit: :minute, factor: 45, offset: 0],
  ninety_minute_increment: [base_unit: :minute, factor: 90, offset: 0],
  one_hundred_twenty_minute_increment: [base_unit: :minute, factor: 120, offset: 0]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Import LiveView Native configuration
import_config "native.exs"
