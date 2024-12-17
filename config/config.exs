# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :klepsidra,
  ecto_repos: [Klepsidra.Repo]

config :klepsidra, Oban,
  engine: Oban.Engines.Lite,
  queues: [default: 10, mailers: 20, events: 50, media: 5],
  repo: Klepsidra.Repo,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       # {"* * * * *", MyApp.MinuteWorker},
       # {"* * * * *", Klepsidra.Workers.ScheduledFtsRebuildWorker, queue: :default},
       # {"0 * * * *", MyApp.HourlyWorker, args: %{custom: "arg"}},
       {"0 * * * *", Klepsidra.Workers.ScheduledFtsRebuildWorker, queue: :default}
       # {"0 0 * * *", MyApp.DailyWorker, max_attempts: 1},
       # {"0 12 * * MON", MyApp.MondayWorker, queue: :scheduled, tags: ["mondays"]},
       # {"@daily", MyApp.AnotherDailyWorker}
     ]}
  ]

config :klepsidra, Klepsidra.TimeTracking.Timer,
  default_date_format: "{WDfull}, {D} {Mshort} {YYYY}",
  default_time_format: "{h24}:{m}"

# Configures the endpoint
config :klepsidra, KlepsidraWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: KlepsidraWeb.ErrorHTML, json: KlepsidraWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Klepsidra.PubSub,
  live_view: [signing_salt: "3h4E5TnT"],
  live_reload: [
    notify: [
      live_view: [
        ~r"lib/klepsidra_web/components/core_components.ex$",
        ~r"lib/klepsidra_web/(live|components)/.*(ex|heex)$"
      ]
    ],
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif)$},
      ~r{lib/klepsidra_web/views/.*(ex)$},
      ~r{lib/klepsidra_web/templates/.*(eex)$}
    ]
  ]

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
  version: "3.4.6",
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

# Configure custom CLDR backend for use
config :ex_cldr,
  default_locale: "en_GB",
  default_backend: Klepsidra.Cldr

# CLDR Units configuration: define custom units
config :ex_cldr_units, :additional_units,
  minute_increment: [base_unit: :second, factor: 60, offset: 0],
  five_minute_increment: [base_unit: :second, factor: 300, offset: 0],
  six_minute_increment: [base_unit: :second, factor: 360, offset: 0],
  ten_minute_increment: [base_unit: :second, factor: 600, offset: 0],
  twelve_minute_increment: [base_unit: :second, factor: 720, offset: 0],
  fifteen_minute_increment: [base_unit: :second, factor: 900, offset: 0],
  eighteen_minute_increment: [base_unit: :second, factor: 1_080, offset: 0],
  twenty_minute_increment: [base_unit: :second, factor: 1_200, offset: 0],
  twenty_four_minute_increment: [base_unit: :second, factor: 1_440, offset: 0],
  thirty_minute_increment: [base_unit: :second, factor: 1_800, offset: 0],
  thirty_six_minute_increment: [base_unit: :second, factor: 2_160, offset: 0],
  fourty_five_minute_increment: [base_unit: :second, factor: 2_700, offset: 0],
  sixty_minute_increment: [base_unit: :second, factor: 3_600, offset: 0],
  hour_increment: [base_unit: :second, factor: 3_600, offset: 0],
  ninety_minute_increment: [base_unit: :second, factor: 5_400, offset: 0],
  one_hundred_twenty_minute_increment: [base_unit: :second, factor: 7_200, offset: 0],
  # Day
  day_increment: [base_unit: :second, factor: 86_400, offset: 0],
  # Week
  week_increment: [base_unit: :second, factor: 604_800, offset: 0],
  # Month
  month_increment: [base_unit: :second, factor: 2_629_800, offset: 0],
  # Quarter
  quarter_increment: [base_unit: :second, factor: 7_889_400, offset: 0],
  # Year
  year_increment: [base_unit: :second, factor: 31_557_600, offset: 0]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
