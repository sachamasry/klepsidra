defmodule Klepsidra.Repo.Migrations.CreateJournalEntriesTagsTable do
  use Ecto.Migration

  def change do
    create table(:journal_entry_tags,
             primary_key: false,
             comment:
               "Journal entry tags table, helping categorise journal entries with tags in a many-to-many relationship"
           ) do
      add(
        :journal_entry_id,
        references(:journal_entries, on_delete: :delete_all, on_update: :update_all, type: :uuid),
        null: false,
        comment: "Foreign key referencing journal entries"
      )

      add(:tag_id, references(:tags, on_delete: :delete_all, on_update: :update_all, type: :uuid),
        null: false,
        comment: "Foreign key referencing tags"
      )

      timestamps()
    end

    create(
      unique_index(:journal_entry_tags, [:journal_entry_id, :tag_id],
        comment: "Composite unique index of `journal_entry_id` and `tag_id` fields"
      )
    )
  end
end
