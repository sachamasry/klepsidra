defmodule Klepsidra.Repo.Migrations.UpdateJournalEntryLocationToForeignKey do
  use Ecto.Migration

  def change do
    alter table(:journal_entries) do
      # Drop the current location column (of type string)
      remove(:location)

      # Add the new location column as a foreign key referencing the `locations_cities` table
      add(:location_id, references(:locations_cities, on_delete: :nothing, type: :uuid),
        null: true
      )
    end
  end
end
