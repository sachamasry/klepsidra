defmodule Klepsidra.Repo.Migrations.CreateTrips do
  use Ecto.Migration

  def change do
    create table(:trips,
             primary_key: false,
             comment:
               "The trips table records user travel, for travel tracking and calculating the number of days spent in a territory, particularly to stay within visa requirements."
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based travel tracker primary key"

      add :user_id, references(:users, on_delete: :nothing, type: :uuid),
        null: false,
        comment: "User reference. Foreign key to `users` table"

      add :country_id,
          references(:locations_countries,
            column: :iso_3_country_code,
            on_delete: :nothing,
            type: :string
          ),
          null: true,
          comment: "Foreign key to `locations_countries` table, ISO-3 country code"

      add :description, :string, comment: "Trip purpose, additional details or context"

      add :entry_date, :date,
        null: false,
        comment: "Date of entry into a country"

      add :exit_date, :date,
        null: true,
        comment: "Date of exit from a country"

      timestamps()
    end

    create index(:trips, [:user_id],
             comment:
               "Index of the trip's `user_id` field, optimising searches filtering or joining by user, such as retrieving all trips for a specific user"
           )

    create index(:trips, [:country_id],
             comment:
               "Index of the trip's `country_id` field, useful for queries filtering trips into specific countries"
           )

    create index(:trips, [:entry_date],
             comment:
               "Index of the trip's `entry_date` field, useful for queries filtering trips based on entry dates"
           )

    create index(:trips, [:exit_date],
             comment:
               "Index of the trip's `exit_date` field, useful for queries filtering trips based on exit dates"
           )

    create index(:trips, [:user_id, :country_id],
             comment:
               "Composite index of the trip's `user_id` and `country_id` fields, optimising searches filtering or joining by user and country combinations"
           )

    create index(:trips, [:user_id, :entry_date],
             comment:
               "Composite index of the trip's `user_id` and `entry_date` fields, optimising searches filtering or joining by user and entry date combinations"
           )

    create index(:trips, [:user_id, :country_id, :entry_date, :exit_date],
             comment:
               "Composite index of the trip's `user_id`, `country_id`, and `entry_` and `exit_date` fields, optimising searches filtering or joining by user, country and date range combinations"
           )
  end
end