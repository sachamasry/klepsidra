defmodule Klepsidra.Repo.Migrations.CreateActivityTypes do
  use Ecto.Migration

  def change do
    create table(:activity_types,
             primary_key: false,
             comment:
               "Activity types improves the application UX by storing default billing rates, which speeds up use of activity timers"
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based activity types primary key"

      add :name, :string,
        null: false,
        comment: "Human-readable activity type, e.g. 'planning', 'research', 'execution', etc."

      add :billing_rate, :decimal,
        default: 0.00,
        comment:
          "Billing rate, assumed to be per hour (a common billing time increment), in the default currency"

      add :active, :boolean,
        default: true,
        null: false,
        comment:
          "Is this activity type still active? Provides an easy way to 'retire' old activity types, where deletion may have unintended consequences"

      timestamps()
    end

    create unique_index(:activity_types, [:name],
             comment: "Unique index on the activity types `name` field"
           )

    create index(:activity_types, [:active],
             comment: "Unique index on the activity types `active` field"
           )
  end
end
