defmodule Klepsidra.Repo.Migrations.CreateJournalEntryTypes do
  use Ecto.Migration

  def change do
    create table(:journal_entry_types,
             primary_key: false,
             comment:
               "Journal entry types improves the application by normalising the journal entry type field to an external table."
           ) do
      add :id, :uuid,
        primary_key: true,
        null: false,
        comment: "UUID-based journal entry types primary key"

      add :name, :string,
        null: false,
        comment: "Human-readable journal entry type, e.g. 'gratitude', 'dreams', 'learning', etc."

      add :description, :text,
        comment: "Any other journal entry type details which may be useful in the future."

      add :active, :boolean,
        default: true,
        null: false,
        comment:
          "Is this journal entry type considered active? An inactive entry type will not show up in lists and select controls"

      timestamps()
    end

    create unique_index(:journal_entry_types, [:name],
             unique: true,
             comment: "Unique index on journal entry type"
           )

    create index(:journal_entry_types, [:active],
             comment: "Index on the journal entry type `active` field"
           )
  end
end
