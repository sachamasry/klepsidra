defmodule Klepsidra.Repo.Migrations.CreateActivityTypes do
  use Ecto.Migration

  def change do
    create table(:activity_types,
             comment:
               "Activity types is a table improving the application UX by storing default billing rates, for use in timed activities"
           ) do
      add :activity_type, :string,
        comment: "Human-readable activity type, e.g. 'planning', 'research', 'execution', etc."

      add :billing_rate, :decimal,
        comment:
          "Billing rate, assumed to be per hour (a common billing time increment), in the default currency"

      add :active, :boolean,
        default: true,
        null: false,
        comment:
          "Is this activity type still active? Provides an easy way to 'retire' old activity types, where deletion may have unintended consequences"

      timestampk()
    end
  end
end
