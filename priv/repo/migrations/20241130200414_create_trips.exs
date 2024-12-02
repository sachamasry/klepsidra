defmodule Klepsidra.Repo.Migrations.CreateTrips do
  use Ecto.Migration

  def change do
    create table(:travel_trips,
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

      add :user_document_id, references(:user_documents, on_delete: :nothing, type: :uuid),
        null: true,
        comment:
          "What document was used to travel into the country? User document reference. Foreign key to `users` table."

      add :country_id,
          references(:locations_countries,
            column: :iso_3_country_code,
            on_delete: :nothing,
            type: :string
          ),
          null: false,
          comment: "Foreign key to `locations_countries` table, ISO-3 country code"

      add :description, :string, comment: "Trip purpose, additional details or context"

      add :entry_date, :date,
        null: false,
        comment: "Date of entry into a country"

      add :entry_point, :string,
        null: true,
        comment: "Location where the user entered the country"

      add :exit_date, :date,
        null: true,
        comment: "Date of exit from a country"

      add :exit_point, :string,
        null: true,
        comment: "Location where the user left the country"

      timestamps()
    end

    create index(:travel_trips, [:user_id],
             comment:
               "Index of the trip's `user_id` field, optimising searches filtering or joining by user, such as retrieving all trips for a specific user"
           )

    create index(:travel_trips, [:user_document_id],
             comment:
               "Index of the trip's `user_document_id` field, optimising searches filtering or joining by user document used, such as retrieving all trips on a specific document"
           )

    create index(:travel_trips, [:country_id],
             comment:
               "Index of the trip's `country_id` field, useful for queries filtering trips into specific countries"
           )

    create index(:travel_trips, [:entry_date],
             comment:
               "Index of the trip's `entry_date` field, useful for queries filtering trips based on entry dates"
           )

    create index(:travel_trips, [:entry_point],
             comment:
               "Index of the trip's `entry_point` field, useful for queries filtering trips based on location of entry into the country"
           )

    create index(:travel_trips, [:exit_date],
             comment:
               "Index of the trip's `exit_date` field, useful for queries filtering trips based on exit dates"
           )

    create index(:travel_trips, [:exit_point],
             comment:
               "Index of the trip's `exit_point` field, useful for queries filtering trips based on location of leaving the country"
           )

    create index(:travel_trips, [:user_id, :country_id],
             comment:
               "Composite index of the trip's `user_id` and `country_id` fields, optimising searches filtering or joining by user and country combinations"
           )

    create index(:travel_trips, [:user_id, :user_document_id, :country_id],
             comment:
               "Composite index of the trip's `user_id`, `user_document_id` and `country_id` fields, optimising searches filtering or joining by user, document used, and country combinations"
           )

    create index(:travel_trips, [:user_id, :entry_date],
             comment:
               "Composite index of the trip's `user_id` and `entry_date` fields, optimising searches filtering or joining by user and entry date combinations"
           )

    create index(
             :travel_trips,
             [:user_id, :user_document_id, :country_id, :entry_date, :exit_date],
             comment:
               "Composite index of the trip's `user_id`, `user_document_id`, `country_id`, and `entry_` and `exit_date` fields, optimising searches filtering or joining by user, document used, country and date range combinations"
           )
  end
end
