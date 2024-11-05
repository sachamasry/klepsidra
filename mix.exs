defmodule Klepsidra.MixProject do
  use Mix.Project

  def project do
    [
      app: :klepsidra,
      name: "Klepsidra",
      version: "0.1.2",
      source: "https://github.com/sachamasry/klepsidra-timer",
      homepage_url: "",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: [
        # The main page in the docs
        main: "Klepsidra",
        # logo: "",
        authors: ["Sacha El Masry"],
        extras: doc_extras(),
        groups_for_modules: doc_groups_for_modules(),
        language: "en-GB"
      ],
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [:ecto, :decimal],
        plt_ignore_apps: [],
        list_unused_filters: true,
        flags: [
          "-Wunmatched_returns",
          :error_handling,
          :underspecs,
          :unknown,
          :unmatched_returns
        ]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "test.watch": :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test
      ]
    ]
  end

  defp doc_groups_for_modules() do
    [
      Schemas: [
        Klepsidra.Accounts.User,
        Klepsidra.BusinessPartners.BusinessPartner,
        Klepsidra.BusinessPartners.Note,
        Klepsidra.Categorisation.ProjectTag,
        Klepsidra.Categorisation.Tag,
        Klepsidra.Categorisation.TimerTags,
        Klepsidra.Journals.JournalEntry,
        Klepsidra.Journals.JournalEntryTypes,
        Klepsidra.Projects.Note,
        Klepsidra.Projects.Project,
        Klepsidra.TimeTracking.ActivityType,
        Klepsidra.TimeTracking.Note,
        Klepsidra.TimeTracking.Timer
      ],
      Contexts: [
        Klepsidra.Accounts,
        Klepsidra.BusinessPartners,
        Klepsidra.Categorisation,
        Klepsidra.Journals,
        Klepsidra.Projects,
        Klepsidra.TimeTracking
      ],
      Utilities: [
        Klepsidra.Math,
        Klepsidra.TimeTracking.TimeUnits
      ],
      Web: [
        KlepsidraWeb,
        KlepsidraWeb.CSP,
        KlepsidraWeb.CoreComponents,
        KlepsidraWeb.Gettext,
        KlepsidraWeb.StartPageLive
      ],
      "Common Locale Data Repository (CLDR)": [
        Klepsidra.Cldr,
        Klepsidra.Cldr.AcceptLanguage,
        Klepsidra.Cldr.Calendar,
        Klepsidra.Cldr.Currency,
        Klepsidra.Cldr.Date,
        Klepsidra.Cldr.Date.Interval,
        Klepsidra.Cldr.DateTime,
        Klepsidra.Cldr.DateTime.Format,
        Klepsidra.Cldr.DateTime.Formatter,
        Klepsidra.Cldr.DateTime.Interval,
        Klepsidra.Cldr.DateTime.Relative,
        Klepsidra.Cldr.Interval,
        Klepsidra.Cldr.List,
        Klepsidra.Cldr.Locale,
        Klepsidra.Cldr.Number,
        Klepsidra.Cldr.Number.Cardinal,
        Klepsidra.Cldr.Number.Format,
        Klepsidra.Cldr.Number.Formatter.Decimal,
        Klepsidra.Cldr.Number.Ordinal,
        Klepsidra.Cldr.Number.PluralRule.Range,
        Klepsidra.Cldr.Number.Symbol,
        Klepsidra.Cldr.Number.System,
        Klepsidra.Cldr.Number.Transliterate,
        Klepsidra.Cldr.Rbnf.NumberSystem,
        Klepsidra.Cldr.Rbnf.Ordinal,
        Klepsidra.Cldr.Rbnf.Spellout,
        Klepsidra.Cldr.Time,
        Klepsidra.Cldr.Time.Interval,
        Klepsidra.Cldr.Unit,
        Klepsidra.Cldr.Unit.Additional
      ]
    ]
  end

  defp doc_extras() do
    [
      "README.md",
      "notebooks/01-klepsidra_timer-motivation_and_prototype.livemd",
      "notebooks/02-klepsidra-datetime-local_manipulations.livemd",
      "notebooks/03-analytics_budgeting_billing.livemd"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Klepsidra.Application, []},
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
      {:private, "> 0.0.0"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 1.0", only: [:dev, :test]},
      {:credo, ">= 0.0.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false},
      {:mix_audit, ">= 0.0.0"},
      {:sobelow, ">= 0.0.0"},
      {:gettext, "~> 0.26.1"},
      {:paraxial, "~> 2.7.7"},
      {:ex_check, "~> 0.16.0", only: [:dev], runtime: false},
      {:doctor, ">= 0.0.0", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_unit_notifier, "~> 1.3", only: :test},
      {:excoveralls, "~> 0.18", only: :test},
      {:phoenix, "~> 1.7.10"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.2"},
      {:floki, ">= 0.30.0"},
      {:phoenix_live_dashboard, "~> 0.8.2"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:nimble_csv, "~> 1.1"},
      {:ex_cldr, "~> 2.37"},
      {:ex_cldr_currencies, "~> 2.13"},
      {:ex_cldr_languages, "~> 0.3.3"},
      {:ex_cldr_units, "~> 3.0"},
      {:ex_cldr_dates_times, "~> 2.0"},
      # Possibly deprecated :all_the_cities
      {:all_the_cities, "~> 0.1.0"},
      # Possibly deprecated :place
      {:place, "~> 0.1"},
      {:location, git: "https://github.com/plausible/location"},
      {:timex, "~> 3.7"},
      {:earmark, "~> 1.4"},
      {:html_sanitize_ex, "~> 1.3"},
      {:live_toast, "~> 0.6.4"},
      {:live_select, "~> 1.4.3"},
      {:color_contrast, "~> 1.1"}
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
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
